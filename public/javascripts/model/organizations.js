// Organization Model

dc.model.Organization = Backbone.Model.extend({});

// Organization Set

dc.model.OrganizationSet = Backbone.Collection.extend({

  resource : 'organizations',
  model    : dc.model.Organization,

  comparator : function(org) {
    return org.get('name').toLowerCase();
  }

});

window.Organizations = new dc.model.OrganizationSet();
