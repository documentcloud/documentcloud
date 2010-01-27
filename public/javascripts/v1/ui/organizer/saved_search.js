dc.ui.SavedSearch = dc.View.extend({

  className : 'saved_search box',

  callbacks : [
    ['el',            'click',    'runSearch'],
    ['.icon.delete',  'click',    'deleteSearch']
  ],

  constructor : function(options) {
    this.base(options);
    this.model.view = this;
  },

  render : function() {
    $(this.el).html(JST.organizer_search(this.model.attributes()));
    this.el.id = "saved_search_" + this.model.cid;
    this.setCallbacks();
    return this;
  },

  runSearch : function() {
    dc.app.searchBox.search(this.model.get('query'));
  },

  deleteSearch : function(e) {
    e.stopPropagation();
    SavedSearches.destroy(this.model);
  }

});
