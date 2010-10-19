// Organization Model

dc.model.Organization = Backbone.Model.extend({

  groupSearchUrl : function() {
    return "/#search/" + encodeURIComponent('group: ' + this.get('slug'));
  }

});

// Organization Set

dc.model.OrganizationSet = Backbone.Collection.extend({

  model : dc.model.Organization,
  url   : '/organizations',

  comparator : function(org) {
    return org.get('name').toLowerCase();
  }

});

window.Organizations = new dc.model.OrganizationSet();
