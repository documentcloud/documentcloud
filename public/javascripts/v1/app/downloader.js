// Simple downloader for the time being. Lazy-load the download iframe.
dc.app.download = function(url) {
  if (!this.iframe) {
    this.iframe = $.el("iframe", {id : 'hidden_iframe', name : 'hidden_iframe', src : 'about:blank', 'class' : 'hidden_iframe'});
    $(document.body).append(this.iframe);
  }
  $(this.iframe).attr({src : url});
};