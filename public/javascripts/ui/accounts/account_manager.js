dc.ui.AccountManager = Backbone.View.extend({
  id: "account_manager_container",
  className: 'accounts_tab_content',

  events: {
    'click .save_changes': 'save_account'
  },

  initialize: function(options){
    this.account = dc.account;
    this.collection = (this.collection || window.Accounts);
    dc.app.navigation.bind('tab:accounts', this.open);
  },
  
  createSubViews: function() {
    
  },
  
  render: function() {
    var html = JST['account/details']({languages: dc.language.NAMES, account: dc.account});
    return this.$el.html(html);
  },
  
  open: function() {
    // note needs a guard against opening
    // accounts panel when in the public workspace
    // or dc.account otherwise isn't set.
    console.log("Opened Account Manager!");
    dc.app.navigation.open('accounts', true);
    Backbone.history.navigate('accounts');
  },
  
  save_account: function() {
    
  }
});