dc.ui.ShareDialog = dc.ui.Dialog.extend({

  id : 'share_dialog',
  
  className : 'account_list dialog',

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
    this.model = options.docs[0];
    $(this.el).hide();
  },

  render : function() {
    dc.ui.Dialog.prototype.render.call(this);
    $(document.body).addClass('overlay');
    this._container = this.$('.custom');
    this._container.setMode('not', 'draggable');
    this.addControl(this.make('div', {'class': 'minibutton dark add_reviewer', style : 'width: 90px;'}, 'Add Reviewer'));
    this.$('.custom').html(JST['account/share_dialog']({model : this.model}));
    this.list = this.$('.account_list_content');
    if (this.model.reviewers.length) {
      this._finishRender();
    } else {
      dc.ui.spinner.show();
      this.model.reviewers.fetch({success : this._finishRender});
    }
    $(this.el).show();
    return this;
  },
  
  _finishRender : function() {
    dc.ui.spinner.hide();
    if (this.model.reviewers.length) {
      var views = this.model.reviewers.map(_.bind(function(account) {
        return (new dc.ui.AccountView({model : account, kind : 'reviewer'})).render(null, {doc : this.model}).el;
      }, this));
      this.$('.reviewer_list tbody').append(views);
      this.$('.reviewers').show();
    }
    $(this.el).show();
    this.center();  
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
    this.model.reviewers.create({email : email}, {
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
  },

  _removeReviewer : function(e) {
    this.showSpinner();
    var reviewers = this.model.reviewers.get(parseInt($(e.target).attr('data-id'), 10));
    reviewers.destroy({
      success : _.bind(function(){ 
        // this.model.set({reviewer_count : this.model.get('reviewer_count') - 1}); 
        this.render(true);
      }, this)
    });
  }


});
