// Organization Model

dc.model.Organization = dc.Model.extend({});

// Organization Set

dc.model.OrganizationSet = dc.model.RESTfulSet.extend({

  resource : 'organizations',

  comparator : function(org) {
    return org.get('name').toLowerCase();
  }

});

dc.model.AccountSet.implement(dc.model.SortedSet);

window.Organizations = new dc.model.OrganizationSet();
