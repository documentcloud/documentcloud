dc.ui.AccountDialog = dc.ui.Dialog.extend({

  id : 'account_list',

  callbacks : {
    '.ok.click'           : 'close',
    '.new_account.click'  : 'newAccount'
  },

  constructor : function() {
    this.base({
      mode          : 'custom',
      title         : dc.app.organization.name,
      information   : 'group: ' + dc.app.organization.slug
    });
    _.bindAll(this, '_renderAccounts');
    this._rendered = false;
    $(this.el).hide();
  },

  render : function() {
    this.base();
    this._rendered = true;
    this._container = $('.custom', this.el);
    this._container.html(JST.account_dialog({}));
    if (Accounts.current().isAdmin()) this.appendControl($.el('div', {'class': 'minibutton dark new_account', style : 'width: 80px;'}, 'New Account'));
    this.list = $('#account_list_content', this.el);
    this.setCallbacks();
    dc.ui.spinner.show('loading');
    Accounts.populate({success : this._renderAccounts});
    return this;
  },

  open : function() {
    if (!this._rendered) return this.render();
    $(document.body).addClass('overlay');
    $(this.el).show();
  },

  close : function() {
    dc.ui.notifier.hide();
    $(this.el).hide();
    $(document.body).removeClass('overlay');
  },

  newAccount : function() {
    var view = new dc.ui.AccountView({model : new dc.model.Account(), kind : 'row'});
    this.list.append(view.render('edit').el);
    this._container[0].scrollTop = this._container[0].scrollHeight;
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
