dc.ui.Project = dc.View.extend({

  className : 'project box',

  callbacks : {
    'el.click'          : 'showDocuments',
    '.org_docs.click'   : 'showOrganizationDocuments',
    '.edit_glyph.click' : 'editProject'
  },

  constructor : function(options) {
    this.base(options);
    if (this.model.get('special')) return this.setMode('special', 'project');
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
    this.model.get('special') ? Accounts.current().openDocuments() : this.model.open();
  },

  showOrganizationDocuments : function() {
    Accounts.current().openOrganizationDocuments();
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
    if (this.myDocuments) $(this.myDocuments.el).setMode('not', 'selected');
    var projectName = dc.app.SearchParser.extractProject(query);
    var project = projectName && Projects.find(projectName);
    if (project) return project.set({selected : true});
    if (type == 'my_documents' || type == 'org_documents') {
      return $(this.myDocuments.el).setMode('is', 'selected');
    }
  }

});
