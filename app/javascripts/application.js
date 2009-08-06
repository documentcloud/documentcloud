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