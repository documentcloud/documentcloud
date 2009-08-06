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
    window.resp = resp;
  }, 'json');
};