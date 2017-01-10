dc.ui.AdminAccounts = Backbone.View.extend({

  render : function() {
    $(this.el).html(JST['admin_accounts']({}));
    var rows = Accounts.map(function(account) {
      return (new dc.ui.AccountView({model : account, kind : 'admin'})).render().el;
    });
    this.$('tbody').append(rows);
    return this;
  },

  isAdmin : function() {
    return this.get('role') == dc.model.Membership.prototype.ADMINISTRATOR;
  }

});
