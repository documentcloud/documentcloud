dc.ui.OrganizationManager = Backbone.View.extend({
  className: 'organization',
  initialize: function(options){
    this.membership = options.membership;
    this.memberViews = this.model.members.map(function(account){ return new dc.ui.AccountView({model: account, kind: 'organization_row', dialog: options.dialog}); }, this);
  },
  render: function() {
    this.$el.html(JST['organization/details']({
      organization: this.model, 
      membership:   this.describeMembership(this.membership),
      languages: dc.language.NAMES
    }));
    this.$('.account_list_content').append(this.memberViews.map(function(view){ return view.render().el; }));
    this.$el.addClass('account_list');
    return this;
  },
  describeMembership: function(membership){
    return "a " + dc.model.Account.prototype.ROLE_NAMES[membership.get('role')] + " for ";
  }
});