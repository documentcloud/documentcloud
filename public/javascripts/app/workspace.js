// Main controller for the workspace. Orchestrates subviews. Handles searching
// (for now). Still needs to be cleaned up. Search should be pulled out.
dc.app.workspace = new dc.View();
_.extend(dc.app.workspace, {
  
  callbacks : [
    ['#search',                 'keydown',    'maybeSearch'],
    ['#wordmark',               'click',      'goHome'],
    ['#upload_document_button', 'click',      'showUploadForm']
  ],
  
  // Initializes the workspace, binding it to <body>.
  initialize : function() {
    this.el = $('body').get();
    
    this.sidebar = new dc.ui.Sidebar();
    $('#content').append(this.sidebar.render().el);
    
    this.panel = new dc.ui.Panel();
    $('#content').append(this.panel.render().el);
    
    this.searchBox = $('#search');
            
    dc.history.register(/^#search\//, function(hash) {
      dc.app.workspace.search(decodeURIComponent(hash));
    });
    
    this.setCallbacks();
    dc.history.loadURL();
  },
  
  // Return to the DocumentCloud homepage.
  goHome : function() {
    window.location = '/';
  },
  
  // Show the document upload form.
  showUploadForm : function() {
    var docUpload = new dc.ui.DocumentUpload();
    this.sidebar.show(docUpload.helpContent());
    this.panel.show(docUpload.render().el);
  },
  
  // Start a search for a query string, updating the page URL.
  search : function(query) {
    this.searchBox.val(query);
    dc.history.save('search/' + encodeURIComponent(query));
    dc.app.workspace.outstandingSearch = true;
    dc.ui.Spinner.show('searching');
    $('.documents').html('');
    dc.app.workspace.sidebar.show('');
    $.get('/search.json', {query_string : query}, this.loadSearchResults, 'json');
  },
  
  // Callback fired on key press in the search box. We search when they hit
  // return.
  maybeSearch : function(e) {
    if (!this.outstandingSearch && e.keyCode == 13 && this.searchBox.val()) {
      this.search(this.searchBox.val());
    }
  },
  
  // Hide the spinner and remove the search lock when finished searching.
  doneSearching : function() {
    dc.ui.Spinner.hide();
    dc.app.workspace.outstandingSearch = false;
  },
  
  // After the initial search results come back, send out a request for the
  // associated metadata, as long as something was found. Think about returning
  // the metadata right alongside the document JSON.
  loadSearchResults : function(resp) {        
    if (window.console) console.log(resp);
    Documents.refresh(_.map(resp.documents, function(m){ 
      return new dc.model.Document(m); 
    }));
    var query = new dc.ui.Query(resp.query).render(resp.documents.length);
    $(dc.app.workspace.sidebar.content).append(query.el);
    dc.app.workspace.panel.show((new dc.ui.DocumentList()).render().el);
    _.each(Documents.values(), function(el) {
      $('.documents').append((new dc.ui.DocumentTile(el)).render().el);
    });
    if (resp.documents.length == 0) return dc.app.workspace.doneSearching();
    dc.ui.Spinner.show('gathering metadata');
    var docIds = _.pluck(resp.documents, 'id');
    $.get('/documents/metadata.json', {'ids[]' : docIds}, 
          dc.app.workspace.loadMetadataResults, 'json');
  },
  
  // When the metadata results come back, render the entity list in the sidebar 
  // afresh.
  loadMetadataResults : function(resp) {
    Metadata.refresh();
    _.each(resp.metadata, function(m){ Metadata.addOrCreate(m); });
    Metadata.sort();
    var mView = new dc.ui.MetadataList({metadata : Metadata.values()});
    $(dc.app.workspace.sidebar.content).append(mView.render().el);
    dc.app.workspace.doneSearching();
  }
  
});