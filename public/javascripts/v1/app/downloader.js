// Simple downloader for the time being. Lazy-load the download iframe.
dc.app.download = function(url) {
  $('#hidden_iframe').attr({src : url});
};