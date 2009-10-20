dc.model.History = dc.Model.extend({
  
  // The interval at which the window location is polled.
  URL_CHECK_INTERVAL : 500,

  // Initialize history with an empty set of handlers.
  constructor : function() {
    this.base({
      handlers : [],
      hash     : window.location.hash
    });
    setInterval(this.checkURL, this.URL_CHECK_INTERVAL);
  },
  
  // Register a history handler. Pass a regular expression that can be used to
  // match your URLs, and the callback to be invoked with the remainder of the
  // hash, when matched.
  register : function(matcher, callback) {
    this.get('handlers').push({matcher : matcher, callback : callback});
  },
  
  // Save a moment into browser history. Make sure you've registered a handler
  // for it. You're responsible for pre-escaping the URL fragment.
  save : function(hash) {
    this.set({hash : '#' + hash});
    window.location.hash = hash;
  },
  
  // Until HTML5's hashchange event is widely supported, we poll the window
  // location for changes to the hash.
  checkURL : function() {
    var current = window.location.hash, previous = dc.history.get('hash');
    if (current != previous && current != decodeURIComponent(previous)) {
      dc.history.loadURL();
    }
  },
  
  // Load the history callback associated with the current page fragment. On
  // pages that support history, this method should be called at page load, 
  // after all the history callbacks have been registered.
  loadURL : function(options) {
    var hash = window.location.hash;
    dc.history.set({hash : hash});
    var matched = _.any(dc.history.get('handlers'), function(handler) {
      if (hash.match(handler.matcher)) {
        handler.callback(hash.replace(handler.matcher, ''));
        return true;
      }
    });
    if (!matched && options.fallback) dc.app.navigation.tab(options.fallback);
  }
  
});

dc.history = new dc.model.History();