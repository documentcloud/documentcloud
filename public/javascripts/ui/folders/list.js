dc.ui.FolderList = dc.View.extend({
  
  id : 'folder_list',
  
  callbacks : [
    ['.saved_search',   'click',    'runSearch']
  ],
  
  constructor : function(options) {
    this.base(options);
    _.bindAll('renderAll', 'renderFolders', 'renderSearches', 'runSearch', this);
    dc.app.navigation.register('documents', this.renderAll);
  },
  
  render : function() {
    $(this.el).html(dc.templates.FOLDER_LIST({}));
    return this;
  },
  
  renderAll : function() {
    if (this.rendered) return;
    this.rendered = true;
    SavedSearches.populate({success : this.renderSearches});
  },
  
  renderFolders : function() {
    
  },
  
  renderSearches : function() {
    var rows = _.map(SavedSearches.models(), function(search) {
      var q = search.get('query');
      return $.el('div', {'class' : 'saved_search', query : q}, q);
    });
    $('#saved_searches', this.el).html(rows);
    this.setCallbacks();
  },
  
  runSearch : function(e) {
    dc.app.searchBox.search($(e.target).attr('query'));
  }
  
});