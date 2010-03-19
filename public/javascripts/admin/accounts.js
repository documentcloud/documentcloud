dc.ui.AdminAccounts = dc.View.extend({

  callbacks : {},

  constructor : function(options) {
    this.base(options);
  },

  render : function() {
    $(this.el).html(JST.admin_accounts({}));
    var rows = _.map(Accounts.models(), function(account) {
      return (new dc.ui.AccountView({model : account, kind : 'admin'})).render().el;
    });
    $('tbody', this.el).append(rows);
    return this;
  }

});