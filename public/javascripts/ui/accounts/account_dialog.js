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
    this._open = false;
    $(this.el).hide();
  },

  render : function() {
    this.base();
    this._rendered = true;
    this._container = $('.custom', this.el);
    this._container.html(JST['account/dialog']({}));
    if (Accounts.current().isAdmin()) this.addControl(this.make('div', {'class': 'minibutton dark new_account', style : 'width: 90px;'}, 'New Account'));
    this.list = $('#account_list_content', this.el);
    this.setCallbacks();
    dc.ui.spinner.show();
    Accounts.populate({success : this._renderAccounts});
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
