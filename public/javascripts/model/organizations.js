// Organization Model

dc.model.Organization = Backbone.Model.extend({
  constructor : function(attrs, options) {
    Backbone.Model.call(this, attrs, options);
    this.members = new dc.model.AccountSet();
    this.members.reset(this.get('members'));
  },  

  groupSearchUrl : function() {
    return "/#search/" + encodeURIComponent(this.query());
  },

  openDocuments : function() {
    dc.app.searcher.search(this.query());
  },

  query : function() {
    return 'group: ' + this.get('slug');
  },

  statistics : function() {
    var docs  = this.get('document_count');
    var notes = this.get('note_count');
    return docs + ' ' + dc.inflector.pluralize('document', docs)
      + ', ' + notes + ' ' + dc.inflector.pluralize('note', notes);
  }


});

// Organization Set

dc.model.OrganizationSet = Backbone.Collection.extend({

  model : dc.model.Organization,
  url   : '/organizations',

  comparator : function(org) {
    return org.get('name').toLowerCase().replace(/^the\s*/, '');
  },

  findBySlug : function(slug) {
    return this.detect(function(org){ return org.get('slug') == slug; });
  }

});

window.Organizations = new dc.model.OrganizationSet();
