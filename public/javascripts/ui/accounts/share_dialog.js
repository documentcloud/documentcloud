dc.ui.ShareDialog = dc.ui.Dialog.extend({

  id : 'share_documents',
  
  className : 'account_list dialog',

  events : {
    'click .ok'           : 'close',
    'click .add_reviewer' : 'addReviewer'
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
    dc.ui.Dialog.prototype.render.call(this, {editor : true});
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

  addReviewer : function() {
    var view = new dc.ui.AccountView({model : new dc.model.Account({
      role : dc.model.Account.prototype.REVIEWER
    }), kind : 'row'});
    this.list.append(view.render('edit').el);
    this._container[0].scrollTop = this._container[0].scrollHeight;
  },

  _renderAccounts : function() {
    dc.ui.spinner.hide();
    var views = Accounts.filter(function(account) {
      return account.get('role') == dc.model.Account.prototype.REVIEWER;
    }).map(function(account) {
      return (new dc.ui.AccountView({model : account, kind : 'row'})).render().el;
    });
    this.list.append(views);
    $(this.el).show();
    this.center();
  }

});
