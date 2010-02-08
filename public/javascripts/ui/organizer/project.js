dc.ui.Project = dc.View.extend({

  className : 'project box',

  callbacks : {
    'el.click'           : 'showDocuments',
    '.edit.click'        : 'editProject'
  },

  constructor : function(options) {
    this.base(options);
    _.bindAll(this, 'loadDocuments', 'render');
    this.model.bind(dc.Model.CHANGED, this.render);
    this.model.view = this;
  },

  render : function() {
    $(this.el).html(JST.organizer_project(this.model.attributes()));
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

  editProject : function(e) {
    $(document.body).append((new dc.ui.ProjectDialog({model : this.model})).render().el);
    return false;
  }

}, {

  // Clear out all open project boxes.
  clearSelection : function() {
    $('#organizer .box').setMode('not', 'open');
  }

});
