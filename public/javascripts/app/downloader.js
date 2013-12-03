// A simple iframe-based downloader that can fire a callback when the download
// has begun.
dc.app.download = function(url, callback) {
  dc.ui.spinner.show();
  var iframe = document.createElement('iframe');
  iframe.src = url;
  iframe.style.display = 'none';
  var timer = setInterval(function(){
    if (iframe.contentDocument.readyState == 'complete') {
      dc.ui.spinner.hide();
      clearInterval(timer);
      if (callback) callback();
      $(iframe).remove();
    }
  }, 100);
  $(document.body).append(iframe);
};