dc.ui.AccountManager = Backbone.View.extend({
  id: "account_manager_container",
  className: 'accounts_tab_content',

  events: {
    'click .save_changes': 'save_account'
  },

  initialize: function(){
    this.model         = dc.account;
    this.organizationViews = {};
    this.createSubViews();
    dc.app.navigation.bind('tab:accounts', this.open);
  },
  
  createSubViews: function() {
    this.model.organizations().each(function(organization){ 
      this.organizationViews[organization.cid] = new dc.ui.OrganizationManager({model: organization});
    }, this);
  },
  
  render: function() {
    this.$el.html( JST['account/details']({ languages: dc.language.NAMES, account: this.model }) );
    this._renderSubViews();
    return this.$el;
  },
  
  _renderSubViews: function() {
    this.$el.append('<div class="organizations"><h2 class="title_box"><span class="title_box_inner">Your Organizations</span></h2></div>');
    this.$('.organizations').append(_.map(this.organizationViews, function(view, cid){ return view.render().el }));
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
