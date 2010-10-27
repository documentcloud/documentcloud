// Fake out all the Firebug methods so as to not break browsers that don't yet
// have a console object.
if (!window.console) {
  var names = ["log", "debug", "info", "warn", "error", "assert", "dir", "dirxml",
  "group", "groupEnd", "time", "timeEnd", "count", "trace", "profile", "profileEnd"];

  window.console = {};
  for (var i = 0; i < names.length; ++i) window.console[names[i]] = function() {};
}

jQuery.extend({

  // Add a debug object to JQuery to contain all debugging methods.
  debug : {

    // Look at all the elements in the document to alert you of any duplicate
    // element ids that might have slipped in by mistake.
    checkForDuplicateIds : function() {
      var dups = {};
      var everything = jQuery('*');
      var ids = everything.map(function(){ return this.id; });
      jQuery.each(ids, function(i) {
        if (this == '') return;
        dups[this] = dups[this] || 0;
        dups[this] += 1;
        if (dups[this] >= 2) console.log('duplicate id found: ' + this, everything[i]);
      });
    }

  }
});

// Reload all of the CSS in each frame on the page.
function reloadCSS(win) {
  win = win || window;
  var links = win.document.getElementsByTagName('link');
  for (var i = 0, l = links.length; i < l; i++) {
    var link = links[i];
    var url = link.href;
    if (url && (/stylesheet/i).test(link.rel)) {
      var newUrl = url.replace(/(&|%5C?)forceReload=\d+/, '');
      var reloader = 'forceReload=' + (new Date().valueOf());
      link.href = newUrl + (newUrl.indexOf('?') >= 0 ? '&' : '?') + reloader;
    }
  }
  for (var i = 0, l = win.frames.length; i < l; i++) {
    reloadCSS(win.frames[i]);
  }
}

