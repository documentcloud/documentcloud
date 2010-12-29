dc.ui.ShareDialog = dc.ui.Dialog.extend({

  id                    : 'share_dialog',
  className             : 'account_list dialog',
  
  events : {
    'click .ok':                            'close',
    'click .add_reviewer':                  '_showEnterEmail',
    'click .minibutton.add':                '_addReviewer',
    'click .remove_reviewer':               '_removeReviewer',
    'click .resend_reviewer':               '_resendInstructions',
    'keypress input[name=reviewer_email]':  '_maybeAddReviewer'
  },

  constructor : function(options) {
    _.bindAll(this, '_loadReviewer');
    var title = options.docs.length == 1 ?
                'Sharing "' + options.docs[0].get('title') + '"' :
                'Sharing ' + options.docs.length + ' Documents';
    dc.ui.Dialog.call(this, {
      mode          : 'custom',
      title         : dc.account.organization.name,
      information   : 'Sharing ' + options.docs.length + Inflector.pluralize(' Document', options.docs.length)
    });
    this.docs = new dc.model.DocumentSet(options.docs);
    this.docs.each(function(doc) {
      doc.collection = Documents;
    });
    this.docsUnfetched    = this.docs.length;
    this.renderedAccounts = {};
    this._boundRender     = [];

    $(this.el).hide().empty();
    dc.ui.spinner.show();
    this._loadReviewers();
  },
  
  _loadReviewers : function() {
    if (this.docs.all(function(doc) { return doc.reviewers.length; })) {
      this.docsUnfetched = 0;
      this._loadReviewer();
    } else {
      this.docs.each(_.bind(function(doc) {
        if (doc.reviewers.length) {
          this.docsUnfetched -= 1;
        } else {
          doc.reviewers.fetch({success : this._loadReviewer});
        }
      }, this));
    }
  },
  
  _loadReviewer : function() {
    this.docsUnfetched -= 1;
    if (this.docsUnfetched <= 0) {
      this.render();
      var views = [];
      // this.commonReviewers = Documents.sharedReviewers(this.docs);
      this._countDocuments();
      this.renderedAccounts = {};
      this.docs.each(_.bind(function(doc) {
        doc.reviewers.each(_.bind(function(account) {
          var accountView = this._renderReviewer(account);
          if (accountView) views.push(accountView);
        }, this));
      }, this));
      
      this.$('.account_list tr:not(.reviewer_management)').remove();
      this.$('.account_list').prepend(views);
      this.$('.document_reviewers_empty').toggle(!_.keys(this.renderedAccounts).length);
    }
  },

  render : function() {
    dc.ui.Dialog.prototype.render.call(this);
    this._container = this.$('.custom');
    this._container.setMode('not', 'draggable');
    this.addControl(this.make('div', {
      'class': 'minibutton dark add_reviewer', 
      style : 'width: 90px;'
    }, 'Add Reviewer'));
    this.$('.custom').html(JST['account/share_dialog']({
      'defaultAvatar' : dc.model.Account.prototype.DEFAULT_AVATAR,
      'docCount': this.docs.length
    }));
    this.list = this.$('.account_list_content');
    $(document.body).addClass('overlay');
    this.center();  
    $(this.el).show();
    dc.ui.spinner.hide();
    this._setPlaceholders();
    return this;
  },
  
  
  _setPlaceholders : function() {
    this.$('input[name=first_name], input[name=last_name]').placeholder();
    this.$('input[name=reviewer_email]').placeholder();
  },
  
  _countDocuments : function() {
    this.accountDocumentCounts = {};
    this.docs.each(_.bind(function(doc) {
      doc.reviewers.each(_.bind(function(account) {
        if (this.accountDocumentCounts[account.id]) {
          this.accountDocumentCounts[account.id] += 1;
        } else {
          this.accountDocumentCounts[account.id] = 1;
        }
      }, this));
    }, this));
  },
  
  _renderReviewer : function(account) {    
    if (account.id in this.renderedAccounts) return;
    
    var view = (new dc.ui.AccountView({
      model : account, 
      kind : 'reviewer'
    })).render('display', {
      documentCount  : this.accountDocumentCounts[account.id],
      documentsCount : this.docs.length
    });
    
    this.renderedAccounts[account.id] = view;
    this._observeReviewer(account, view);
    
    return view.el;
  },
  
  _rerenderReviewer : function(account) {
    this.renderedAccounts[account.id].render('display', {
      documentCount  : this.accountDocumentCounts[account.id],
      documentsCount : this.docs.length
    });
  },

  _observeReviewer : function(account, view) {
    account.unbind('change', view._boundRender);
    if (this._boundRender[account.id]) account.unbind('change', this._boundRender[account.id]);
    this._boundRender[account.id] = _.bind(this._rerenderReviewer, this, account);
    account.bind('change', this._boundRender[account.id]);
  },
  
  _showEnterEmail : function() {
    var $reviewers = this.$('.document_reviewers');
    this.$('.reviewer_management').show();
    this.$('.add_reviewer').hide();
    $reviewers.attr('scrollTop', $reviewers.attr("scrollHeight")+100);
    this.$('#reviewer_email').focus();
    this.$('.document_reviewers_empty').hide();
  },
  
  _maybeAddReviewer : function(e) {
    if (e.keyCode == 13) this._addReviewer();
  },
  
  _addReviewer : function() {
    var email = this.$('#reviewer_email').val();
    if (!email) return this._showManagementError('Please enter an email address.');
    this.showSpinner();
    $.ajax({
      url : '/documents/reviewers/add',
      type : 'POST',
      data : {
        email : email,
        first_name : this.$('input[name=first_name]').val(),
        last_name : this.$('input[name=last_name]').val(),
        documents : this.docs.map(function(doc) { return doc.id; })
      },
      success: _.bind(function(resp) {
        _.each(resp.documents, function(doc) {
          Documents.get(doc.id).set(doc);
        });
        var account = new dc.model.Account(resp.account);
        this.docs.each(_.bind(function(doc) {
          if (!_.contains(doc.reviewers.map(function(r) { return r.id; }), account.id)) {
            doc.reviewers.add(account);
          }
        }, this));
        dc.ui.notifier.show({
          text      : 'Document review instructions sent to ' + resp.account['email'],
          duration  : 5000,
          mode      : 'info'
        });
        this._loadReviewers();
      }, this),
      error : _.bind(function(resp) {
        resp = JSON.parse(resp.responseText);
        if (_.any(resp.errors, function(error) {
          error = error.toLowerCase();
          return error.indexOf("first name") != -1 || error.indexOf("last name") != -1;
        })) {
          this._showReviewerNameInputs();
          this._showManagementError("Please enter in the full name for this reviewer.");
        } else {
          this._showManagementError(resp.errors[0]);
        }
        this.hideSpinner();
      }, this)
    });
  },
  
  _showManagementError : function(error) {
    this.$('.reviewer_management .last').text(error);
  },
  
  _showReviewerNameInputs : function() {
    this.$('input[name=first_name], input[name=last_name]').show();
    this.$('.enter_full_name_label').show();
    this.$('.enter_email_label').hide();
    this._setPlaceholders();
  },

  _removeReviewer : function(e) {
    this.showSpinner();
    var accountId = parseInt($(e.target).attr('data-account-id'), 10);
    var accounts  = _.flatten(this.docs.map(function(doc){ return doc.reviewers.models; }));
    var account   = _.detect(accounts, function(acc){ return acc.id == accountId; });
    var reviewerDocuments = this.docs.select(function(doc) {
      return doc.reviewers.any(function(r) { return r.get('id') == account.get('id'); });
    });
    var documentIds = _.map(reviewerDocuments, function(d) { return d.get('id'); });
    
    $.ajax({
      url : '/documents/reviewers/remove',
      type : 'POST',
      data : {
        account_id : accountId,
        documents : documentIds
      },
      success: _.bind(function(resp) {
        _.each(resp, function(doc) {
          Documents.get(doc.id).set(doc);
        });
        this.docs.each(_.bind(function(doc) {
          if (_.contains(documentIds, doc.id)) {
            doc.reviewers.remove(account);
          }
        }, this));
        dc.ui.notifier.show({
          text      : account.get('email') + ' is no longer a reviewer on ' + documentIds.length + Inflector.pluralize(' document', documentIds.length),
          duration  : 5000,
          mode      : 'info'
        });
        this._loadReviewers();
      }, this),
      error : _.bind(function(resp) {
        this.hideSpinner();
        this._showManagementError('There was a problem removing the reviewer.');
      }, this)
    });
  },
  
  _resendInstructions : function(e) {
    this.showSpinner();
    var accountId = parseInt($(e.target).attr('data-account-id'), 10);
    var accounts  = _.flatten(this.docs.map(function(doc){ return doc.reviewers.models; }));
    var account   = _.detect(accounts, function(acc){ return acc.id == accountId; });
    var reviewerDocuments = this.docs.select(function(doc) {
      return doc.reviewers.any(function(r) { return r.get('id') == account.get('id'); });
    });
    var documentIds = _.map(reviewerDocuments, function(d) { return d.get('id'); });
    
    $.ajax({
      url : '/documents/reviewers/resend',
      type : 'POST',
      data : {
        account_id : accountId,
        documents : documentIds
      },
      success: _.bind(function(resp) {
        this.hideSpinner();
        dc.ui.notifier.show({
          text      : account.get('email') + ' has been resent reviewing instructions for ' + documentIds.length + Inflector.pluralize(' document', documentIds.length) + '.',
          duration  : 5000,
          mode      : 'info'
        });
      }, this),
      error : _.bind(function(resp) {
        this.hideSpinner();
        this._showManagementError('There was a problem resending instructions.');
      }, this)
    });
    
  },
  
  close : function() {
    dc.ui.notifier.hide();
    $(this.el).hide();
    $(document.body).removeClass('overlay');
  }

});
