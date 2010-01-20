// Bookmark Model

dc.model.Bookmark = dc.Model.extend({

  resource : 'bookmarks',

  viewClass : 'Bookmark',

  sortKey : function() {
    return this.get('title').toLowerCase() + this.get('page_number');
  },

  url : function() {
    return '/bookmarks/' + this.id;
  }

});


// Bookmarks Set

dc.model.BookmarkSet = dc.model.RESTfulSet.extend({

  resource : 'bookmarks'

});

window.Bookmarks = new dc.model.BookmarkSet();
