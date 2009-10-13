dc.model.AccountSet = dc.model.RESTfulSet.extend({
  
  resource : 'accounts',

  constructor : function() {
    this.base();
    this.bind(dc.Set.MODEL_CHANGED, this.onModelChanged);
  },
  
  onModelChanged : function(e, set, model) {
    this.update(model);
  },
  
  // Fetch the account of the logged-in journalist.
  current : function() {
    return this.get(dc.app.accountId);
  },
  
  // Lazy-fetch all the organization's DocumentCloud accounts.
  fetch : function(callback) {
    var me = this;
    dc.ui.Spinner.show('fetching accounts...');
    $.get('/accounts', {}, function(resp) {
      dc.ui.Spinner.hide();
      _.each(resp.accounts, function(attrs){ 
        var account = new dc.model.Account(attrs);
        if (!Accounts.include(account)) Accounts.add(account);
      });
      if (callback) callback();
    }, 'json');
  }
  
});

window.Accounts = new dc.model.AccountSet();
