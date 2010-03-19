dc.ui.AdminAccounts = dc.View.extend({

  callbacks : {},

  constructor : function(options) {
    this.base(options);
  },

  render : function() {
    $(this.el).html(JST.admin_accounts({}));
    var body = $('tbody', this.el);
    _.each(Accounts.models(), function(account) {
      body.append((new dc.ui.AccountView({model : account, kind : 'row'})).render().el);
    });
    return this;
  }

});