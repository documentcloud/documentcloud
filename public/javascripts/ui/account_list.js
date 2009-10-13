dc.ui.AccountList = dc.View.extend({
  
  id : 'account_list',
  className : 'panel',
  
  constructor : function(options) {
    this.base(options);
    _.bindAll('renderAccounts', this);
    dc.app.navigation.register('accounts', this.renderAccounts);
  },
  
  renderAccounts : function() {
    var el = $(this.el);
    if (Accounts.empty()) Accounts.fetch(function() {
      Accounts.each(function(account) {
        el.append(account.toString());
      });
    });
  }
  
});