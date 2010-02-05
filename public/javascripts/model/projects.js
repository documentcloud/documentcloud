// Project Model

dc.model.Project = dc.Model.extend({

  resource : 'projects',

  viewClass : 'Project',

  documentIds : function() {
    if (!this.get('document_ids')) return [];
    return this.get('document_ids').split(',');
  },

  documentCount : function() {
    return this.documentIds().length;
  },

  addDocuments : function(documents) {
    var ids = _.pluck(documents, 'id');
    var newIds = _.uniq(this.documentIds().concat(ids));
    Projects.update(this, {document_ids : newIds.join(',')});
  },

  // Return the title of this project as a search parameter.
  toSearchParam : function() {
    var titlePart = this.get('title');
    if (titlePart.match(/\s/)) titlePart = '"' + titlePart + '"';
    return 'project: ' + titlePart;
  }

});


// Project Set

dc.model.ProjectSet = dc.model.RESTfulSet.extend({

  resource : 'projects',

  comparator : function(m) {
    return m.get('title').toLowerCase();
  },

  // Find a project by title.
  find : function(title) {
    return _.detect(this.models(), function(m){ return m.get('title').toLowerCase() == title.toLowerCase(); });
  },

  // Find all projects starting with a given prefix, for autocompletion.
  startingWith : function(prefix) {
    var matcher = new RegExp('^' + prefix);
    return _.select(this.models(), function(m){ return !!m.get('title').match(matcher); });
  }

});

dc.model.ProjectSet.implement(dc.model.SortedSet);
window.Projects = new dc.model.ProjectSet();
