// The search controller is responsible for managing document/metadata search.
dc.ui.SearchBox = dc.View.extend({
  
  fragment : null,
    
  callbacks : [
    ['el',  'keydown',  'maybeSearch']
  ],
  
  // Creating a new SearchBox registers #search page fragments.
  constructor : function() {
    this.base({el : $('#search')[0]});
    this.outstandingSearch = false;
    this.setCallbacks();
    _.bindAll('loadSearchResults', 'loadMetadataResults', 'searchByHash', this);
    dc.history.register(/^#search\//, this.searchByHash);
  },
  
  // Shortcut to the searchbox's value.
  value : function(query) {
    return $(this.el).val(query);
  },
  
  // Start a search for a query string, updating the page URL.
  search : function(query) {
    if (dc.app.navigation) dc.app.navigation.tab('documents');
    this.value(query);
    this.fragment = 'search/' + encodeURIComponent(query);
    dc.history.save(this.fragment);
    this.outstandingSearch = true;
    dc.ui.Spinner.show('searching');
    $('.documents').html('');
    $('#metadata_container').html('');
    $('#query_container').html('');
    $.get('/search.json', {query_string : query}, this.loadSearchResults, 'json');
  },
  
  // When searching by the URL's hash value, we need to unescape first.
  searchByHash : function(hash) {
    this.search(decodeURIComponent(hash));
  },
  
  // Callback fired on key press in the search box. We search when they hit
  // return.
  maybeSearch : function(e) {
    if (!this.outstandingSearch && e.keyCode == 13 && this.value()) {
      this.search(this.value());
    }
  },
  
  // Hide the spinner and remove the search lock when finished searching.
  doneSearching : function() {
    dc.ui.Spinner.hide();
    this.outstandingSearch = false;
  },
  
  // After the initial search results come back, send out a request for the
  // associated metadata, as long as something was found. Think about returning
  // the metadata right alongside the document JSON.
  loadSearchResults : function(resp) {        
    Documents.refresh(_.map(resp.documents, function(m){ 
      return new dc.model.Document(m); 
    }));
    var query = new dc.ui.Query(resp.query).render(resp.documents.length);
    $('#query_container').html(query.el);
    $('#document_list_container').html((new dc.ui.DocumentList()).render().el);
    _.each(Documents.values(), function(el) {
      $('.documents').append((new dc.ui.DocumentTile(el)).render().el);
    });
    if (resp.documents.length == 0) return this.doneSearching();
    dc.ui.Spinner.show('gathering metadata');
    var docIds = _.pluck(resp.documents, 'id');
    $.get('/documents/metadata.json', {'ids[]' : docIds}, this.loadMetadataResults, 'json');
  },
  
  // When the metadata results come back, render the entity list in the sidebar 
  // afresh.
  loadMetadataResults : function(resp) {
    Metadata.refresh();
    _.each(resp.metadata, function(m){ Metadata.addOrCreate(m); });
    Metadata.sort();
    var mView = new dc.ui.MetadataList({metadata : Metadata.values()});
    $('#metadata_container').html(mView.render().el);
    this.doneSearching();
  }
  
});