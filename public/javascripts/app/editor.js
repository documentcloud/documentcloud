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
    dc.ui.Dialog.prototype.DEFAULT_OPTIONS.buttons = 'mini';
    $('#DV-docViewer').addClass('DV-isEditor');
    $('#DV-well').append(this.controlPanel.render().el);
    var desc = $('#DV-descriptionHead');
    desc.html(desc.html().replace(/Summary/, 'Description'));
    // if (this.isOwner) $('#DV-textContents').attr({contentEditable : 'true'});
  },

  notify : function(options) {
    dc.ui.notifier.show(_.extend({
      anchor    : $('#control_panel'),
      position  : 'bottom -left',
      left      : 14,
      top       : 10
    }, options));
  }

});