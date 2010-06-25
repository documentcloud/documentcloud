// Project Model

dc.model.Project = dc.Model.extend({

  constructor : function(options) {
    this.base(options);
    this.collaborators = new dc.model.AccountSet();
    this._setCollaboratorsResource();
  },

  set : function(attrs, silent) {
    if (attrs.document_ids)     attrs.document_count = attrs.document_ids.length;
    if (attrs.account_id)       attrs.owner = attrs.account_id == dc.app.accountId;
    if (attrs.collaborator_ids) attrs.collaborator_count = attrs.collaborator_ids.length;
    this.base(attrs, silent);
    if (attrs.id) this._setCollaboratorsResource();
    return this;
  },

  open : function() {
    dc.app.searchBox.search(this.toSearchParam());
  },

  documentCount : function() {
    return this.get('document_ids').length;
  },

  addDocuments : function(documents) {
    var ids = _.pluck(documents, 'id');
    var newIds = _.uniq(this.get('document_ids').concat(ids));
    Projects.update(this, {document_ids : newIds});
  },

  removeDocuments : function(documents, localOnly) {
    var args = _.pluck(documents, 'id');
    args.unshift(this.get('document_ids'));
    var newIds = _.without.apply(_, args);
    if (localOnly) {
      this.set({document_ids : newIds});
    } else {
      Projects.update(this, {document_ids : newIds});
    }
  },

  // Does this project already contain a given document?
  contains : function(doc) {
    return _.indexOf(this.get('document_ids'), doc.id) >= 0;
  },

  // Does this project already contain any of the given documents?
  containsAny : function(docs) {
    var me = this;
    return _.any(docs, function(doc){ return me.contains(doc); });
  },

  // Return the title of this project as a search parameter.
  toSearchParam : function() {
    var titlePart = this.get('title');
    if (titlePart.match(/\s/)) titlePart = '"' + titlePart + '"';
    return 'project: ' + titlePart;
  },

  statistics : function() {
    var docCount    = this.get('document_count');
    var noteCount   = this.get('annotation_count');
    var shareCount  = this.get('collaborator_count');
    return docCount + ' ' + Inflector.pluralize('document', docCount)
      + ', ' + noteCount + ' ' + Inflector.pluralize('note', noteCount)
      + (shareCount ? ', ' + shareCount + ' ' + Inflector.pluralize('collaborator', shareCount) : '');
  },

  _setCollaboratorsResource : function() {
    if (this.collaborators && this.id) this.collaborators.resource = 'projects/' + this.id + '/collaborators';
  }

}, {

  topLevelTitle : function(type) {
    switch (type) {
      case 'all_documents':   return 'All Documents';
      case 'your_documents':  return 'Your Documents';
      case 'org_documents':   return Inflector.possessivize(dc.app.organization.name) + " Documents";
    }
  }

});


// Project Set
dc.model.ProjectSet = dc.model.RESTfulSet.extend({

  resource : 'projects',
  model    : dc.model.Project,

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
  },

  // Increment the document_count attribute of a given project, by id.
  incrementCountById : function(id) {
    var project = this.get(id);
    project.set({document_count : project.get('document_count') + 1});
  },

  // When documents are deleted, remove all of their matches.
  removeDocuments : function(docs) {
    _.each(this.models(), function(project) {
      project.removeDocuments(docs, true);
    });
  }

});

dc.model.ProjectSet.implement(dc.model.SelectableSet);
dc.model.ProjectSet.implement(dc.model.SortedSet);

window.Projects = new dc.model.ProjectSet();
