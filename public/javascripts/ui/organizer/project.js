dc.ui.Project = dc.View.extend({

  className : 'project box',

  callbacks : {
    'el.click'           : 'showDocuments',
    '.edit.click'        : 'editProject'
  },

  constructor : function(options) {
    this.base(options);
    if (!this.model) {
      this.setMode('uploaded', 'documents');
      dc.ui.Project.uploadedDocuments = this;
      return;
    }
    _.bindAll(this, 'render');
    this.model.bind(dc.Model.CHANGED, this.render);
    this.model.view = this;
  },

  render : function() {
    var data = this.model ? this.model.attributes() : this.defaultProjectAttributes();
    $(this.el).html(JST.organizer_project(data));
    if (this.model) $(this.el).attr({id : "project_" + this.model.cid, 'data-project-cid' : this.model.cid});
    this.setCallbacks();
    return this;
  },

  // Attributes for the default "Uploaded Documents" project.
  defaultProjectAttributes : function() {
    return {
      title             : 'Uploaded Documents',
      document_count    : dc.app.documentCount,
      annotation_count  : dc.app.annotationCount
    };
  },

  showDocuments : function() {
    this.model ? this.model.open() : Accounts.current().openDocuments();
  },

  showOpen : function() {
    $(this.el).setMode('is', 'open');
  },

  editProject : function(e) {
    $(document.body).append((new dc.ui.ProjectDialog({model : this.model})).render().el);
    return false;
  }

}, {

  // (Maybe) hightlight a project box for the current query.
  highlight : function(query) {
    this.clearSelection();
    var projectName = dc.app.SearchParser.extractProject(query);
    var project = projectName && Projects.find(projectName);
    if (project) return project.view.showOpen();
    var accountName = dc.app.SearchParser.extractAccount(query);
    var account = accountName && (accountName == Accounts.current().get('email'));
    if (account) return $(this.uploadedDocuments.el).setMode('is', 'open');
  },

  // Clear out all open project boxes.
  clearSelection : function() {
    $('#organizer .box').setMode('not', 'open');
  }

});
