dc.ui.Project = dc.View.extend({

  className : 'project box',

  callbacks : {
    'el.click'           : 'showDocuments',
    '.icon.delete.click' : 'deleteProject'
  },

  constructor : function(options) {
    this.base(options);
    _.bindAll(this, 'loadDocuments', 'render');
    this.model.bind(dc.Model.CHANGED, this.render);
    this.model.view = this;
  },

  render : function() {
    var data = {
      title           : this.model.get('title'),
      document_count  : this.model.documentCount(),
      note_count      : this.model.get('annotation_count')
    };
    $(this.el).html(JST.organizer_project(data));
    $(this.el).attr({id : "project_" + this.model.cid, 'data-project-cid' : this.model.cid});
    this.setCallbacks();
    return this;
  },

  showDocuments : function() {
    dc.app.searchBox.search(this.model.toSearchParam());
  },

  showOpen : function() {
    dc.ui.Project.clearSelection();
    $(this.el).setMode('is', 'open');
  },

  deleteProject : function(e) {
    e.stopPropagation();
    Projects.destroy(this.model);
  }

}, {

  // Clear out all open project boxes.
  clearSelection : function() {
    $('#organizer .box').setMode('not', 'open');
  }

});
