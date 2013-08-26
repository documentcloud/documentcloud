dc.ui.AccountManager = Backbone.View.extend({
  id: "account_manager",
  events: {},
  initialize: function(options){
    this.account = dc.account;
    this.collection = (this.collection || window.Accounts)
    this.createSubViews();
    dc.app.navigation.bind('tab:accounts', this.open);
  },
  
  createSubViews: function() {
    
  },
  
  render: function() {
    
  },
  
  open: function() {
    console.log("Opened Account Manager!");
    dc.app.navigation.open('accounts');
    Backbone.history.navigate('accounts');
  }
});