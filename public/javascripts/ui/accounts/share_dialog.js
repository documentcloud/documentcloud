dc.ui.ShareDialog = dc.ui.Dialog.extend({

  id : 'share_documents',
  
  className : 'account_list dialog',

  events : {
    'click .ok'           : 'close',
    'click .add_reviewer' : 'addReviewer'
  },

  constructor : function(options) {
    dc.ui.Dialog.call(this, {
      mode          : 'custom',
      title         : dc.account.organization.name,
      information   : 'Sharing ' + options.docs.length + Inflector.pluralize(' Document', options.docs.length)
    });
    $(this.el).hide();
  },

  render : function() {
    dc.ui.Dialog.prototype.render.call(this);
    $(document.body).addClass('overlay');
    this._container = this.$('.custom');
    this._container.setMode('not', 'draggable');
    this._container.html(JST['account/dialog']({}));
    this.addControl(this.make('div', {'class': 'minibutton dark add_reviewer', style : 'width: 90px;'}, 'Add Reviewer'));
    this.list = this.$('#account_list_content');
    this._renderAccounts();
    this.center();
    $(this.el).show();
    return this;
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
