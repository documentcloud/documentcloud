dc.ui.ShareDialog = dc.ui.Dialog.extend({

  id : 'share_dialog',
  
  className : 'account_list dialog',

  commonReviewers : [],
  renderedCommonReviewers : [],
  
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
    this.renderedCommonReviewers = [];
    this.addControl(this.make('div', {
      'class': 'minibutton dark add_reviewer', 
      style : 'width: 90px;'
    }, 'Add Reviewer'));
    this.$('.custom').html(JST['account/share_dialog']({}));
    this.list = this.$('.account_list_content');
    if (this.docs.all(function(doc) { return doc.reviewers.length; })) {
      this._finishRender(true);
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
    $(this.el).show();
    return this;
  },
  
  _finishRender : function(loaded) {
    this.docsUnfetched -= 1;
    if (this.docsUnfetched <= 0 || loaded) {
      $(this.el).hide();
      this.$('.document_reviewers').empty();
      if (this.docs.length > 1) {
        this.commonReviewers = Documents.sharedReviewers(this.docs);
        if (this.commonReviewers.length) {
          this._renderReviewerGroup('common', 'Common');
        }
      }
      this.docs.each(_.bind(function(doc) {
        this._renderReviewerGroup(doc.get('id'), doc.get('title'), doc.get('thumbnail_url'));
        if (doc.reviewers.length) {
          doc.reviewers.each(_.bind(function(account) {
            this._renderReviewer(account, doc);
          }, this));
        } else {
          this.$('.reviewers_'+doc.get('id')+' .reviewer_list').append(this.make('div', { 
            'class' : 'reviewers_empty'
          }, 'No reviewers.'));
        }
      }, this));
      $(this.el).show();
      this.center();  
      this.hideSpinner();
    }
  },
  
  _renderReviewer : function(account, doc) {
    var isCommon = _.contains(this.commonReviewers, account.get('id'));
    var group = '.reviewers_' + (isCommon ? 'common' : doc.get('id'));
    
    if (isCommon) {
      if (!_.contains(this.renderedCommonReviewers, account.get('id'))) {
        this.renderedCommonReviewers.push(account.get('id'));
      } else {
        return;
      }
    }
    
    var view = (new dc.ui.AccountView({
      model : account, 
      kind : 'reviewer'
    })).render(null, {doc : doc}).el;
    this.$(group + ' .reviewer_list').append(view);
  },
  
  _renderReviewerGroup : function(group, title, thumbnailUrl) {
    this.$('.document_reviewers').append(JST['account/reviewer_group']({
      group        : group,
      groupTitle   : title,
      thumbnailUrl : thumbnailUrl
    }));
  },
  
  close : function() {
    dc.ui.notifier.hide();
    $(this.el).hide();
    $(document.body).removeClass('overlay');
  },
  
  _showEnterEmail : function() {
    this.$('.add_reviewer').hide();
    this.$('.enter_email').show();
    this.$('#reviewer_email').focus();
  },
  
  _addReviewer : function() {
    var email = this.$('#reviewer_email').val();
    if (!email) return this.error('Please enter an email address.');
    this.showSpinner();
    this.docs.each(_.bind(function(doc) {
      doc.reviewers.create({email : email}, {
        success : _.bind(function(acc, resp) {
          // this.model.set({reviewers_count : this.model.get('reviewers_count') + 1});
          dc.ui.notifier.show({
            text      : 'Document review instructions sent to ' + acc.get('email'),
            duration  : 5000,
            mode      : 'info'
          });
          this.render(true);
        }, this),
        error   : _.bind(function(acc, resp) {
          this.hideSpinner();
          console.log(['error', acc, resp, arguments]);
          if (resp.status == 409) {
            this.error('You cannot add yourself as a reviewer.');
          } else {
            this.error('Unable to use that email.');
          }
        }, this)
      });
    }, this));
  },

  _removeReviewer : function(e) {
    this.showSpinner();
    var docId = $(e.target).parents('.reviewers').attr('data-doc-id');
    if (docId == 'common') {
      var reviewers = this.docs.map(function(doc) {
        doc.reviewers.get(parseInt($(e.target).attr('data-id'), 10));
      });
    } else {
      var doc = this.docs.detect(function(doc) { return doc.get('id') == parseInt(docId, 10); });
      var reviewers = [doc.reviewers.get(parseInt($(e.target).attr('data-id'), 10))];
    }
    
    _.each(reviewers, _.bind(function(reviewer) {
      reviewer.destroy({
        success : _.bind(function(){ 
          // this.model.set({reviewer_count : this.model.get('reviewer_count') - 1}); 
          this.render(true);
        }, this)
      });
    }, this));
  }


});

