// Provide top-level namespaces for our javascript.

(function() {
  window.dc = {};
  dc.model = {};
  dc.util = {};
  dc.app = {};
  dc.ui = {};
})();

// TEST TEST TEST
// For serious.
// TEST TEST TEST
$(document).ready(function() {
  // Move this somewhere. Prevent '#' links from page jumping.
  $('body').bind('click', function(e){
    if (e.target.tagName.toUpperCase() == 'A' && 
      e.target.href == window.location.toString() + '#') e.preventDefault();
  });
  
  $('#workspace_document_list').html((new dc.ui.DocumentList()).render().el);
  
  
  var el = $('#search');
  el.bind('keydown', function(e) {
    if (e.keyCode == 13) {
      dc.ui.Spinner.show('searching');
      $('#metadata').html('');
      $.get('/search.json', {query_string : el.attr('value')}, function(resp) {        
        if (window.console) console.log(resp);
        
        Documents.refresh(_.map(resp.documents, function(m){ return new dc.model.Document(m); }));
        
        var query = new dc.ui.Query(resp.query).render(resp.documents.length);
        $('#query_container').html(query.el);
        
        $('.documents').html('');
        $(resp.documents).each(function() {
          $('.documents').append((new dc.ui.DocumentTile(this)).render().el);
        });
        
        if (resp.documents.length == 0) return dc.ui.Spinner.hide();
        
        dc.ui.Spinner.show('gathering metadata');
        $.get('/documents/metadata.json', {'ids[]' : _.pluck(resp.documents, 'id')}, function(resp2) {
          
          Metadata.refresh();
          _.each(resp2.metadata, function(m){ Metadata.addOrCreate(m); });
          Metadata.sort();
          var mView = new dc.ui.CategorizedMetadata({metadata : Metadata.values()});
          $('#metadata').html(mView.render().el);
          
          dc.ui.Spinner.hide();
        }, 'json');
      }, 'json');
    }
  });
});
