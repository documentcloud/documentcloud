// Provide top-level namespaces for our javascript.

(function() {
  window.dc = {};
  dc.model = {};
  dc.util = {};
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
      dc.ui.Spinner.show('searching');
      $.get('/search.json', {query_string : el.attr('value')}, function(resp) {        
        if (window.console) console.log(resp);
        
        $('#query').html(new dc.ui.Query(resp.query).render(resp.documents.length));
        
        $('#documents').html('');
        $(resp.documents).each(function() {
          $('#documents').append((new dc.ui.DocumentTile(this)).render());
        });
        
        if (resp.documents.length == 0) return dc.ui.Spinner.hide();
        
        dc.ui.Spinner.show('gathering metadata');
        $.get('/documents/metadata.json', {'ids[]' : _.pluck(resp.documents, 'id')}, function(resp2) {
          var sorted = _.sortBy(resp2.metadata, function(meta){ return -meta.relevance; });
          var metaHash = _.inject(sorted, {}, function(memo, meta) {
            var val = meta.value;
            memo[val] = memo[val] || meta;
            if (meta.relevance > memo[val].relevance) memo[val] = meta;
            return memo;
          });
          var text = _.map(metaHash, function(pair) { return "<span title='type:" + pair.value.type + " relevance:" + pair.value.relevance + "'>" + pair.key + "</span>"; }).join(' / ');
          $('#metadata').html(text);
          dc.ui.Spinner.hide();
        }, 'json');
      }, 'json');
    }
  });
});
