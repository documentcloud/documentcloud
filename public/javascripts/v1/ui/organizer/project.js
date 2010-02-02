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
    var data = {
      title           : this.model.get('title'),
      document_count  : this.model.documentCount(),
      note_count      : this.model.get('annotation_count')
    };
    $(this.el).html(JST.organizer_project(data));
    this.el.id = "project_" + this.model.cid;
    this.setCallbacks();
    return this;
  },

  showDocuments : function() {
    $('#organizer .box').setMode('not', 'open');
    $(this.el).setMode('is', 'open');
    dc.app.searchBox.search(this.model.toSearchParam());
  },

  deleteProject : function(e) {
    e.stopPropagation();
    Projects.destroy(this.model);
  }

});
