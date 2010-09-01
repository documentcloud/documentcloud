// Main controller for the in-viewer document editor. Orchestrates subviews.
dc.app.editor = new dc.View();
_.extend(dc.app.editor, {

  // Initializes the workspace, binding it to <body>.
  initialize : function(docId, isOwner) {
    this.el = $('body')[0];
    this.docId = docId;
    this.isOwner = isOwner;
    this.createSubViews();
    this.renderSubViews();
  },

  // Create all of the requisite subviews.
  createSubViews : function() {
    dc.ui.notifier          = new dc.ui.Notifier();
    this.controlPanel       = new dc.ui.ViewerControlPanel();
    this.sectionEditor      = new dc.ui.SectionEditor();
    this.annotationEditor   = new dc.ui.AnnotationEditor();
  },

  // Render all of the existing subviews and place them in the DOM.
  renderSubViews : function() {
    var access = this.isOwner ? 'DV-isOwner' : 'DV-isContributor';
    $('.DV-docViewer').addClass(access);
    $('.DV-well').append(this.controlPanel.render().el);
    $('.DV-logo').hide();
  }

});