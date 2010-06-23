dc.ui.Project = dc.View.extend({

  TOP_LEVEL_SEARCHES : {
    all_documents   : 'showAllDocuments',
    your_documents  : 'showYourDocuments',
    org_documents   : 'showOrganizationDocuments'
  },

  className : 'project box',

  callbacks : {
    'el.click'              : 'showDocuments',
    '.all_documents.click'  : 'showAllDocuments',
    '.org_documents.click'  : 'showOrganizationDocuments',
    '.your_documents.click' : 'showYourDocuments',
    '.edit_glyph.click'     : 'editProject'
  },

  constructor : function(options) {
    this.base(options);
    if (this.model.get('current')) return this.setMode('special', 'project');
    _.bindAll(this, 'render');
    this.model.bind(dc.Model.CHANGED, this.render);
    this.model.view = this;
  },

  render : function() {
    $(this.el).html(JST.organizer_project(this.model.attributes()));
    $(this.el).attr({id : "project_" + this.model.cid, 'data-project-cid' : this.model.cid});
    this.setMode(this.model.get('selected') ? 'is' : 'not', 'selected');
    this.setCallbacks();
    return this;
  },

  showDocuments : function() {
    var current = this.model.get('current');
    if (!current) return this.model.open();
    this[this.TOP_LEVEL_SEARCHES[current]]();
  },

  showOrganizationDocuments : function() {
    Accounts.current().openOrganizationDocuments();
    return false;
  },

  showAllDocuments : function() {
    dc.app.searchBox.search('');
    return false;
  },

  showYourDocuments : function() {
    Accounts.current().openDocuments();
    return false;
  },

  editProject : function(e) {
    $(document.body).append((new dc.ui.ProjectDialog({model : this.model})).render().el);
    return false;
  }

}, {

  // (Maybe) hightlight a project box for the current query.
  highlight : function(query, type) {
    Projects.deselectAll();
    if (this.allDocuments) $(this.allDocuments.el).setMode('not', 'selected');
    var projectName = dc.app.SearchParser.extractProject(query);
    var project = projectName && Projects.find(projectName);
    if (project) return project.set({selected : true});
    if (type == 'your_documents' || type == 'org_documents' || type == 'all_documents') {
      dc.app.preferences.set({top_level_search : type});
      this.allDocuments.model.set({current : type});
      this.allDocuments.render();
      this.allDocuments.setMode('is', 'selected');
    }
  }

});
