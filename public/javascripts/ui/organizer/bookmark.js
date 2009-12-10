dc.ui.Bookmark = dc.View.extend({

  className : 'bookmark box serif',

  callbacks : [
    ['el',            'click',    'openBookmark'],
    ['.icon.delete',  'click',    'deleteBookmark']
  ],

  constructor : function(options) {
    this.base(options);
    this.model.view = this;
  },

  render : function() {
    $(this.el).html(JST.organizer_bookmark(this.model.attributes()));
    this.el.id = "bookmark_" + this.model.cid;
    this.setCallbacks();
    return this;
  },

  openBookmark : function() {
    window.open(this.model.url());
  },

  deleteBookmark : function(e) {
    e.stopPropagation();
    Bookmarks.destroy(this.model);
  }

});
