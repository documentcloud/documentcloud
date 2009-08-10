// Provide top-level namespaces for our javascript.

(function() {
  window.dc = {};
  dc.model = {};
  dc.app = {};
  dc.ui = {};
})();


// TEST TEST TEST
window.fetch_documents = function() {
  $.get('/documents/test.json', {}, function(resp) {
    console.log(resp);
    $(resp.documents).each(function() {
      $('#documents').append((new dc.ui.DocumentTile(this)).render());
    });
  }, 'json');
};

// TEST TEST TEST
$(document).ready(function() {
  var el = $('#search');
  el.bind('keydown', function(e) {
    if (e.keyCode == 13) {
      $.get('/search.json', {query_string : el.attr('value')}, function(resp) {
        if (window.console) console.log(resp);
        $('#documents').html('');
        $(resp.documents).each(function() {
          $('#documents').append((new dc.ui.DocumentTile(this)).render());
        });
      }, 'json');
    }
  });
});
