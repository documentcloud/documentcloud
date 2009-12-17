dc.ui.ViewerControlPanel = dc.View.extend({

  id : 'control_panel',

  callbacks : [
    ['.bookmark_page',  'click',  'bookmarkCurrentPage'],
    ['.set_sections',   'click',  'openSectionEditor'],
    ['.add_annotation', 'click',  'openAnnotationEditor']
  ],

  render : function() {
    $(this.el).html(JST.viewer_control_panel({isOwner : dc.app.editor.isOwner}));
    this.setCallbacks();
    return this;
  },

  openSectionEditor : function() {
    dc.app.editor.sectionEditor.open();
  },

  openAnnotationEditor : function() {
    dc.app.editor.annotationEditor.open();
  },

  bookmarkCurrentPage : function() {
    var bookmark = new dc.model.Bookmark({
      title       : DV.Schema.data.title,
      page_number : DV.controller.models.document.currentPage(),
      document_id : dc.app.editor.docId
    });
    var openerMarks = (window.opener && window.opener.Bookmarks);
    Bookmarks.create(bookmark, null, {
      success : function(model, resp) {
        bookmark.set(resp);
        if (openerMarks) openerMarks.add(bookmark);
        dc.app.editor.notify({mode: 'info', text : 'bookmark saved'});
      },
      error : function() {
        dc.app.editor.notify({mode : 'warn', text : 'bookmark already exists'});
      }
    });
  }

});