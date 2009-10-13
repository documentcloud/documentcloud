dc.ui.AccountList = dc.View.extend({
  
  id        : 'account_list',
  className : 'panel',
  rendered  : false,
  
  callbacks : [
    ['.new_account',    'click',    'newAccount']
  ],
  
  constructor : function(options) {
    this.base(options);
    _.bindAll('renderAccounts', this);
    dc.app.navigation.register('accounts', this.renderAccounts);
  },
  
  renderAccounts : function() {
    if (this.rendered) return;
    this.rendered = true;
    $(this.el).append(dc.templates.ACCOUNT_LIST({}));
    var list = this.list = $('#account_list_content', this.el);
    this.setCallbacks();
    Accounts.fetch(function() {
      Accounts.each(function(account) {
        var row = new dc.ui.AccountView(account, 'row');
        window.row = row;
        list.append(row.render().el);
      });
    });
  },
  
  newAccount : function() {
    var view = new dc.ui.AccountView(new dc.model.Account(), 'row');
    this.list.append(view.render('edit').el);
  }
  
});