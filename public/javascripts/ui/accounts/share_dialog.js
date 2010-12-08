dc.ui.ShareDialog = dc.ui.Dialog.extend({

  id : 'share_dialog',
  
  className : 'account_list dialog',

  accountDocumentCounts : {},
  renderedAccounts : [],
  
  events : {
    'click .ok'                     : 'close',
    'click .add_reviewer'           : '_showEnterEmail',
    'click .minibutton.add'         : '_addReviewer',
    'click .remove'                 : '_removeReviewer'
  },

  constructor : function(options) {
    _.bindAll(this, '_finishRender');
    var title = options.docs.length == 1 ?
                'Sharing "' + options.docs[0].get('title') + '"' :
                'Sharing ' + options.docs.length + ' Documents';
    dc.ui.Dialog.call(this, {
      mode          : 'custom',
      title         : dc.account.organization.name,
      information   : 'Sharing ' + options.docs.length + Inflector.pluralize(' Document', options.docs.length)
    });
    this.docs = (new Backbone.Collection(options.docs));
    this.docsUnfetched = this.docs.length;
    $(this.el).hide();
  },

  render : function() {
    dc.ui.Dialog.prototype.render.call(this);
    $(document.body).addClass('overlay');
    this._container = this.$('.custom');
    this._container.setMode('not', 'draggable');
    this.addControl(this.make('div', {
      'class': 'minibutton dark add_reviewer', 
      style : 'width: 90px;'
    }, 'Add Reviewer'));
    this.$('.custom').html(JST['account/share_dialog']({
      'defaultAvatar' : dc.model.Account.prototype.DEFAULT_AVATAR
    }));
    this.list = this.$('.account_list_content');
    if (this.docs.all(function(doc) { return doc.reviewers.length; })) {
      this.docsUnfetched = 0;
      this._finishRender();
    } else {
      this.showSpinner();
      this.docs.each(_.bind(function(doc) {
        if (doc.reviewers.length) {
          this.docsUnfetched -= 1;
        } else {
          doc.reviewers.fetch({success : this._finishRender});
        }
      }, this));
    }
    this._setPlaceholders();
    $(this.el).show();
    return this;
  },
  
  _finishRender : function() {
    this.docsUnfetched -= 1;
    if (this.docsUnfetched <= 0) {
      var views = [];
      // this.commonReviewers = Documents.sharedReviewers(this.docs);
      this._countDocuments();
      this.renderedAccounts = [];
      this.docs.each(_.bind(function(doc) {
        doc.reviewers.each(_.bind(function(account) {
          var accountView = this._renderReviewer(account);
          if (accountView) views.push(accountView);
        }, this));
      }, this));
      
      this.$('.account_list tr:not(.reviewer_management)').remove();
      this.$('.account_list').prepend(views);
      this.center();  
      this.hideSpinner();
    }
  },
  
  _setPlaceholders : function(includeNames) {
    if (includeNames) {
      this.$('input[name=reviewer_first_name], input[name=reviewer_last_name]').placeholder();
    }
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
    if (_.contains(this.renderedAccounts, account.id)) return;
    else this.renderedAccounts.push(account.id);
    
    var view = (new dc.ui.AccountView({
      model : account, 
      kind : 'reviewer'
    })).render(null, {
      documentCount  : this.accountDocumentCounts[account.id],
      documentsCount : this.docs.length
    }).el;
    
    return view;
  },
  
  _showEnterEmail : function() {
    this.$('.reviewer_management').show();
    this.$('.add_reviewer').hide();
    // this.$('#reviewer_email').focus();
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
        first_name : this.$('input[name=reviewer_first_name]').val(),
        last_name : this.$('input[name=reviewer_last_name]').val(),
        documents : this.docs.map(function(doc) { return doc.id; })
      },
      success: _.bind(function(resp) {
        var account = new dc.model.Account(resp);
        this.docs.each(_.bind(function(doc) {
          if (!_.contains(doc.reviewers.map(function(r) { return r.id; }), account.id)) {
            doc.reviewers.add(account);
          }
        }, this));
        dc.ui.notifier.show({
          text      : 'Document review instructions sent to ' + resp['email'],
          duration  : 5000,
          mode      : 'info'
        });
        this.render(true);
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
    this.$('input[name=reviewer_first_name], input[name=reviewer_last_name]').show();
    this.$('.enter_full_name_label').show();
    this.$('.enter_email_label').hide();
    this._setPlaceholders(true);
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
        this.render(true);
      }, this),
      error : _.bind(function(resp) {
        this.hideSpinner();
        this._showManagementError('There was a problem removing the reviewer.');
      }, this)
    });
    
  },
  
  close : function() {
    dc.ui.notifier.hide();
    $(this.el).hide();
    $(document.body).removeClass('overlay');
  }

});
