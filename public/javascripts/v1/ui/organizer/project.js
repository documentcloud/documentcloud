dc.ui.Project = dc.View.extend({

  className : 'project box',

  callbacks : {
    'el.click'           : 'showDocuments',
    '.icon.delete.click' : 'deleteProject'
    // 'el.dragenter'       : '_onDragEnter',
    // 'el.dragover'        : '_onDragEnter',
    // 'el.drop'            : '_onDrop',
    // 'el.dragleave'       : '_onDragLeave'
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

  // _onDragEnter : function(e) {
  //   e.preventDefault();
  //   $(this.el).addClass('hover');
  //   try {
  //     e.dataTransfer.effectAllowed = 'all';
  //     e.dataTransfer.dropEffect = 'copy';
  //   } catch(e) {}
  // },
  //
  // _onDrop : function(e) {
  //   e.preventDefault();
  //   var url = e.originalEvent.dataTransfer.getData('text/plain');
  //   var match = url.match(/\/documents\/\d+/);
  //   if (!match) return false;
  //   $(this.el).removeClass('hover');
  // },
  //
  // _onDragLeave : function(e) {
  //   e.preventDefault();
  //   $(this.el).removeClass('hover');
  // }

});
