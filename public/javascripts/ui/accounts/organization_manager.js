dc.ui.OrganizationManager = Backbone.View.extend({
  className: 'organization',

  events: {
    'click .save_changes': 'saveOrganization',
    'click .new_account' : 'newAccount'
  },

  initialize: function(options){
    this.dialog = options.dialog;
    this.membership = options.membership;
    this.memberViews = this.model.members.map(function(account){ 
      return new dc.ui.AccountView({model: account, kind: 'row', dialog: this.dialog}); 
    }, this);
  },

  render: function() {
    this.$el.html(JST['organization/details']({
      organization: this.model, 
      membership:   this.describeMembership(this.membership),
      languages: dc.language.NAMES
    }));
    this.list = this.$('.account_list_content');
    this.list.append(this.memberViews.map(function(view){ return view.render().el; }));
    this.$el.addClass('account_list');
    return this;
  },

  describeMembership: function(membership){
    return "a " + dc.model.Account.prototype.ROLE_NAMES[membership.get('role')] + " for ";
  },

  newAccount : function() {
    console.log("new account");
    var view = new dc.ui.AccountView({
      model : new dc.model.Account(),
      kind : 'row',
      dialog : this.dialog
    });
    this.list.prepend(view.render('edit').el);
  },
  
  saveOrganization: function() { console.log('saving') }
});