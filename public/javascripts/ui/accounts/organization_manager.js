dc.ui.OrganizationManager = Backbone.View.extend({
  initialize: function(options){
    this.memberViews = this.model.members.map(function(account){ return new dc.ui.AccountView({model: account, kind: 'row'}); });
  },
  render: function() {
    this.$el.html("<h3>"+this.model.get("name")+"</h3>"+JST['account/dialog']());
    this.$('.account_list_content').append(this.memberViews.map(function(view){ return view.render().el; }));
    return this;
  }
});