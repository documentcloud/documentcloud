dc.ui.AccountList = dc.View.extend({
  
  id        : 'account_list',
  className : 'panel',
  rendered  : false,
  
  callbacks : [
    ['.new_account',    'click',    'newAccount']
  ],
  
  constructor : function(options) {
    this.base(options);
    _.bindAll('renderAccounts', 'ensureRendered', this);
    dc.app.navigation.register('admin', this.ensureRendered);
  },
  
  ensureRendered : function() {
    if (this.rendered) return;
    this.rendered = true;
    $(this.el).append(JST.account_list({}));
    this.list = $('#account_list_content', this.el);
    this.setCallbacks();
    Accounts.populate({success : this.renderAccounts});
  },
  
  renderAccounts : function() {
    var list = this.list;
    Accounts.each(function(account) {
      var row = new dc.ui.AccountView(account, 'row');
      window.row = row;
      list.append(row.render().el);
    });
  },
  
  newAccount : function() {
    var view = new dc.ui.AccountView(new dc.model.Account(), 'row');
    this.list.append(view.render('edit').el);
  }
  
});