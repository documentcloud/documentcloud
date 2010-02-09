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
  },

  render : function() {
    this.base();
    this._rendered = true;
    $('.custom', this.el).html(JST.account_dialog({}));
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
    $(this.el).hide();
  },

  newAccount : function() {
    var view = new dc.ui.AccountView(new dc.model.Account(), 'row');
    this.list.append(view.render('edit').el);
  },

  _renderAccounts : function() {
    dc.ui.spinner.hide();
    var views = _.map(Accounts.models(), function(account) {
      return (new dc.ui.AccountView(account, 'row')).render().el;
    });
    this.list.append(views);
    $(this.el).show();
    this.center();
  }

});
