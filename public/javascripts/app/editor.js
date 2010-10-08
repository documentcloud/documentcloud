// Main controller for the in-viewer document editor. Orchestrates subviews.
dc.app.editor = new Backbone.View();
_.extend(dc.app.editor, {

  // Initializes the workspace, binding it to <body>.
  initialize : function(docId, isOwner, accountName) {
    this.el = $('body')[0];
    this.docId = docId;
    this.isOwner = isOwner;
    this.accountName = accountName;
    _.defer(_.bind(function() {
      this.createSubViews();
      this.renderSubViews();
    }, this));
  },

  // Create all of the requisite subviews.
  createSubViews : function() {
    dc.ui.notifier          = new dc.ui.Notifier();
    this.controlPanel       = new dc.ui.ViewerControlPanel();
    this.sectionEditor      = new dc.ui.SectionEditor();
    this.annotationEditor   = new dc.ui.AnnotationEditor();
    this.removePagesEditor  = new dc.ui.RemovePagesEditor();
    this.reorderPagesEditor = new dc.ui.ReorderPagesEditor();
    this.editPageTextEditor = new dc.ui.EditPageTextEditor();
    this.addPagesEditor     = new dc.ui.AddPagesEditor();
  },

  // Render all of the existing subviews and place them in the DOM.
  renderSubViews : function() {
    var access = this.isOwner ? 'DV-isOwner' : 'DV-isContributor';
    $('.DV-docViewer').addClass(access);
    $('.DV-well').append(this.controlPanel.render().el);
    $('.DV-logo').hide();
  },
  
  closeAllEditors : function() {
    this.removePagesEditor.close();
    this.reorderPagesEditor.close();
    this.editPageTextEditor.close();
    this.addPagesEditor.close();
  }

});