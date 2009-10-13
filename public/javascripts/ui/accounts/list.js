dc.ui.AccountList = dc.View.extend({
  
  id        : 'account_list',
  className : 'panel',
  rendered  : false,
  
  constructor : function(options) {
    this.base(options);
    _.bindAll('renderAccounts', this);
    dc.app.navigation.register('accounts', this.renderAccounts);
  },
  
  renderAccounts : function() {
    if (this.rendered) return;
    this.rendered = true;
    $(this.el).append(dc.templates.ACCOUNT_LIST({}));
    var content = $('#account_list_content', this.el);
    if (Accounts.empty()) Accounts.fetch(function() {
      Accounts.each(function(account) {
        var row = new dc.ui.AccountView(account, 'row');
        window.row = row;
        content.append(row.render().el);
      });
    });
  }
  
});