// Handles JavaScript history management and callbacks. To use, register a
// regexp that matches the history hash with its corresponding callback.
dc.history = {

  // The interval at which the window location is polled.
  URL_CHECK_INTERVAL : 500,

  // We need to use an iFrame to save history if we're in an old version of IE.
  USE_IFRAME : jQuery.browser.msie && jQuery.browser.version < 8,

  // The ordered list of history handlers matchers and callbacks.
  handlers : [],

  // The current recorded window.location.hash.
  hash : window.location.hash,

  // Initialize history with an empty set of handlers.
  // Bind to the HTML5 'onhashchange' callback, if it exists. Otherwise,
  // start polling the window location.
  initialize : function() {
    _.bindAll(this, 'checkURL');
    if (this.USE_IFRAME) this.iframe = jQuery('<iframe src="javascript:0"/>').hide().appendTo('body')[0].contentWindow;
    if ('onhashchange' in window) {
      window.onhashchange = this.checkURL;
    } else {
      setInterval(this.checkURL, this.URL_CHECK_INTERVAL);
    }
  },

  // Register a history handler. Pass a regular expression that can be used to
  // match your URLs, and the callback to be invoked with the remainder of the
  // hash, when matched.
  register : function(matcher, callback) {
    this.handlers.push({matcher : matcher, callback : callback});
  },

  // Save a moment into browser history. Make sure you've registered a handler
  // for it. You're responsible for pre-escaping the URL fragment.
  save : function(hash) {
    var next = hash ? '#' + hash : '';
    if (this.hash == next) return;
    window.location.hash = this.hash = next;
    if (this.USE_IFRAME && (this.hash != this.iframe.location.hash)) {
      this.iframe.document.open().close();
      this.iframe.location.hash = this.hash;
    }
  },

  // Check the current URL hash against the recorded one, firing callbacks.
  checkURL : function() {
    var current = (this.USE_IFRAME ? this.iframe : window).location.hash;
    if (current == this.hash ||
        '#' + current == this.hash ||
        current == decodeURIComponent(this.hash)) return false;
    if (this.USE_IFRAME) window.location.hash = current;
    this.loadURL();
  },

  // Load the history callback associated with the current page fragment. On
  // pages that support history, this method should be called at page load,
  // after all the history callbacks have been registered.
  loadURL : function() {
    var hash = this.hash = window.location.hash;
    var matched = _.any(this.handlers, function(handler) {
      if (hash.match(handler.matcher)) {
        handler.callback(hash.replace(handler.matcher, ''));
        return true;
      }
    });
    if (!matched && !hash) dc.app.searchBox.clearSearch();
  }

};
