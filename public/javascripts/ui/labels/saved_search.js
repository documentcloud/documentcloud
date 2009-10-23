dc.ui.SavedSearch = dc.View.extend({
  
  className : 'saved_search box',
  
  callbacks : [
    ['el',              'click',    'runSearch'],
    ['.delete_bullet',  'click',    'deleteSearch']
  ],
  
  constructor : function(options) {
    this.base(options);
    this.model.view = this;
  },
  
  render : function() {
    $(this.el).html(dc.templates.LABEL_SEARCH(this.model.attributes()));
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
