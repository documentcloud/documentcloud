dc.ui.AccountDialog = dc.ui.Dialog.extend({
  
  id : 'account_list',
  
  className : 'account_list dialog',

  events : {
    'click .ok'           : 'close',
    'click .new_account'  : 'newAccount'
  },

  constructor : function() {
    dc.ui.Dialog.call(this, {
      mode          : 'custom',
      title         : 'Manage Accounts: ' + dc.account.organization.name,
      information   : 'group: ' + dc.account.organization.slug
    });
    Accounts.bind('reset', _.bind(this._renderAccounts, this));
    this._rendered = false;
    this._open = false;
    $(this.el).hide();
  },

  render : function() {
    dc.ui.Dialog.prototype.render.call(this);
    this._rendered = true;
    this._container = this.$('.custom');
    this._container.setMode('not', 'draggable');
    this._container.html(JST['account/dialog']({}));
    if (Accounts.current().isAdmin()) this.addControl(this.make('div', {'class': 'minibutton dark new_account', style : 'width: 90px;'}, 'New Account'));
    this.list = this.$('.account_list_content');
    this._renderAccounts();
    return this;
  },

  open : function() {
    this._open = true;
    if (!this._rendered) {
      this.render();
      return;
    }
    $(document.body).addClass('overlay');
    this.center();
    $(this.el).show();
  },

  close : function() {
    dc.ui.notifier.hide();
    $(this.el).hide();
    $(document.body).removeClass('overlay');
    this._open = false;
  },

  isOpen : function() {
    return this._open;
  },

  newAccount : function() {
    var view = new dc.ui.AccountView({
      model : new dc.model.Account(), 
      kind : 'row',
      dialog : this
    });
    this.list.append(view.render('edit').el);
    this._container[0].scrollTop = this._container[0].scrollHeight;
  },

  _renderAccounts : function() {
    dc.ui.spinner.hide();
    var views = Accounts.map(function(account) {
      return (new dc.ui.AccountView({model : account, kind : 'row'})).render().el;
    });
    this.list.append(views);
    $(this.el).show();
    this.center();
  }

});
