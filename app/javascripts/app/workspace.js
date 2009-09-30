// Main controller for the workspace.
dc.app.workspace = {
  
  // On Document ready, bind all callbacks.
  initialize : function() {
    $(document).ready(function() { dc.app.workspace.load(); });
  },
  
  load : function() {
    // Move this somewhere. Prevent '#' links from page jumping.
    $('body').bind('click', function(e){
      if (e.target.tagName.toUpperCase() == 'A' && e.target.href == window.location.toString() + '#') {
        e.preventDefault();
      }
    });
    
    this.sidebar = new dc.ui.Sidebar();
    $('#content').append(this.sidebar.render().el);
    
    this.panel = new dc.ui.Panel();
    $('#content').append(this.panel.render().el);
        
    var el = $('#search');
    el.bind('keydown', function(e) {
      if (!el.outstandingSearch && e.keyCode == 13 && el.val()) {
        dc.app.workspace.search(el.val());
      }
    });
    
    $('#wordmark').click(function(){ window.location = '/'; });
    
    $('#upload_document_button').click(function(){ dc.app.workspace.showUploadForm(); });
    
    this.performDefaultSearch();
  },
  
  showUploadForm : function() {
    var docUpload = new dc.ui.DocumentUpload();
    this.sidebar.show(docUpload.helpContent());
    this.panel.show(docUpload.render().el);
  },
  
  search : function(query) {
    var el = $('#search');
    el.outstandingSearch = true;
    dc.ui.Spinner.show('searching');
    $('.documents').html('');
    this.sidebar.show('');
    $.get('/search.json', {query_string : query}, function(resp) {        
      if (window.console) console.log(resp);

      Documents.refresh(_.map(resp.documents, function(m){ return new dc.model.Document(m); }));

      var query = new dc.ui.Query(resp.query).render(resp.documents.length);
      $(dc.app.workspace.sidebar.content).append(query.el);

      dc.app.workspace.panel.show((new dc.ui.DocumentList()).render().el);
      _.each(Documents.values(), function(el) {
        $('.documents').append((new dc.ui.DocumentTile(el)).render().el);
      });

      if (resp.documents.length == 0) {
        dc.ui.Spinner.hide();
        el.outstandingSearch = false;
        return;
      }

      dc.ui.Spinner.show('gathering metadata');
      $.get('/documents/metadata.json', {'ids[]' : _.pluck(resp.documents, 'id')}, function(resp2) {

        Metadata.refresh();
        _.each(resp2.metadata, function(m){ Metadata.addOrCreate(m); });
        Metadata.sort();
        var mView = new dc.ui.MetadataList({metadata : Metadata.values()});
        $(dc.app.workspace.sidebar.content).append(mView.render().el);

        dc.ui.Spinner.hide();
        el.outstandingSearch = false;
      }, 'json');
    }, 'json');
  },
  
  performDefaultSearch : function() {
    var query = window.SEARCH_QUERY;
    if (query) {
      $('#search').val(query);
      this.search(query);
    }
  }
  
};