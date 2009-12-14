dc.ui.ViewerControlPanel = dc.View.extend({

  id : 'control_panel',

  callbacks : [
    ['#bookmark_page',  'click',  'bookmarkCurrentPage']
  ],

  render : function() {
    $(this.el).html(JST.viewer_control_panel({}));
    this.setCallbacks();
    return this;
  },

  notify : function(options) {
    dc.ui.notifier.show({
      mode      : options.mode,
      text      : options.text,
      anchor    : $('#DV-views'),
      position  : 'center right',
      left      : 10
    });
  },

  bookmarkCurrentPage : function() {
    var bookmark = new dc.model.Bookmark({
      title       : DV.Schema.data.title,
      page_number : DV.controller.models.document.currentPage(),
      document_id : dc.app.editor.docId
    });
    var openerMarks = (window.opener && window.opener.Bookmarks);
    Bookmarks.create(bookmark, null, {
      success : _.bind(function(model, resp) {
        bookmark.set(resp);
        openerMarks.add(bookmark);
        this.notify({mode: 'info', text : 'bookmark saved'});
      }, this),
      error : _.bind(function() {
        this.notify({mode : 'warn', text : 'bookmark already exists'});
      }, this)
    });
  }

});