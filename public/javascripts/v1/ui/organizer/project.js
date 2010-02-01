dc.ui.Project = dc.View.extend({

  className : 'project box',

  callbacks : {
    'el.click':           'showDocuments',
    '.icon.delete.click': 'deleteProject'
  },

  constructor : function(options) {
    this.base(options);
    _.bindAll(this, 'loadDocuments');
    this.model.view = this;
  },

  render : function() {
    $(this.el).html(JST.organizer_project(this.model.attributes()));
    this.el.id = "project_" + this.model.cid;
    this.setCallbacks();
    return this;
  },

  showDocuments : function() {
    dc.app.searchBox.search(this.model.toSearchParam());
  },

  deleteProject : function(e) {
    e.stopPropagation();
    Projects.destroy(this.model);
  }

});
