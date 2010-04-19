// Organization Model

dc.model.Organization = dc.Model.extend({});

// Organization Set

dc.model.OrganizationSet = dc.model.RESTfulSet.extend({

  resource : 'organizations',
  model    : dc.model.Organization,

  comparator : function(org) {
    return org.get('name').toLowerCase();
  }

});

dc.model.OrganizationSet.implement(dc.model.SortedSet);

window.Organizations = new dc.model.OrganizationSet();
