dc.model.AccountSet = dc.model.RESTfulSet.extend({
  
  resource : 'accounts',
  
  // Fetch the account of the logged-in journalist.
  current : function() {
    return this.get(dc.app.accountId);
  },
  
  // Lazy-fetch all the organization's DocumentCloud accounts.
  fetch : function(callback) {
    var me = this;
    dc.ui.spinner.show('fetching accounts');
    $.get('/accounts', {}, function(resp) {
      dc.ui.spinner.hide();
      _.each(resp.accounts, function(attrs){ 
        var account = new dc.model.Account(attrs);
        if (!Accounts.include(account)) Accounts.add(account);
      });
      if (callback) callback();
    }, 'json');
  }
  
});

window.Accounts = new dc.model.AccountSet();
