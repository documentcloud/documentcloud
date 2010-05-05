// Simple downloader for the time being.
dc.app.download = function(url) {
  $('#hidden_iframe').attr({src : url});
};