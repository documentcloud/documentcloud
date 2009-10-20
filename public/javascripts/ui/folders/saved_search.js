dc.ui.SavedSearch = dc.View.extend({
  
  className : 'saved_search',
  
  callbacks : [
    ['el',          'click',    'runSearch'],
    ['.delete_search',  'click',    'deleteSearch']
  ],
  
  constructor : function(options) {
    this.base(options);
    this.model.view = this;
  },
  
  render : function() {
    $(this.el).html(dc.templates.FOLDER_SEARCH(this.model.attributes()));
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
