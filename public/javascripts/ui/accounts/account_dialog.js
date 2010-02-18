dc.ui.AccountDialog = dc.ui.Dialog.extend({

  id : 'account_dialog',

  callbacks : {
    '.ok.click'           : 'close',
    '.new_account.click'  : 'newAccount'
  },

  constructor : function() {
    this.base({
      mode      : 'custom',
      title     : " Accounts: " + dc.app.organization.name
    });
    _.bindAll(this, '_renderAccounts');
    this._rendered = false;
    $(this.el).hide();
  },

  render : function() {
    this.base();
    this._rendered = true;
    $('.custom', this.el).html(JST.account_dialog({}));
    if (Accounts.current().isAdmin()) this.appendControl($.el('button', {'class': 'new_account'}, 'New Account'));
    this.list = $('#account_list_content', this.el);
    this.setCallbacks();
    dc.ui.spinner.show('loading');
    Accounts.populate({success : this._renderAccounts});
    return this;
  },

  open : function() {
    if (!this._rendered) return this.render();
    $(this.el).show();
  },

  close : function() {
    dc.ui.notifier.hide();
    $(this.el).hide();
  },

  newAccount : function() {
    var view = new dc.ui.AccountView({model : new dc.model.Account(), kind : 'row'});
    this.list.append(view.render('edit').el);
  },

  _renderAccounts : function() {
    dc.ui.spinner.hide();
    var views = _.map(Accounts.models(), function(account) {
      return (new dc.ui.AccountView({model : account, kind : 'row'})).render().el;
    });
    this.list.append(views);
    $(this.el).show();
    this.center();
  }

});
