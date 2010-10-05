// Organization Model

dc.model.Organization = Backbone.Model.extend({});

// Organization Set

dc.model.OrganizationSet = Backbone.Collection.extend({

  model : dc.model.Organization,

  url : function() {
    return '/organizations';
  },

  comparator : function(org) {
    return org.get('name').toLowerCase();
  }

});

window.Organizations = new dc.model.OrganizationSet();
