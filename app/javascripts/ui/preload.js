// Preload all images that should be...
(function() {
  
  var preloads = [
    'documents/generic.png',
    'documents/generic_small.png'
  ];
  
  _.each(preloads, function(path) {
    var i = new Image();
    i.src = '/images/' + path;
  });
  
})();