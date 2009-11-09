// Fake out all the Firebug methods so as to not break browsers that don't yet
// have a console object.
if (!window.console) {
  var names = ["log", "debug", "info", "warn", "error", "assert", "dir", "dirxml",
  "group", "groupEnd", "time", "timeEnd", "count", "trace", "profile", "profileEnd"];

  window.console = {};
  for (var i = 0; i < names.length; ++i) window.console[names[i]] = function() {};
}

$.extend({

  // Add a debug object to JQuery to contain all debugging methods.
  debug : {

    // Look at all the elements in the document to alert you of any duplicate
    // element ids that might have slipped in by mistake.
    checkForDuplicateIds : function() {
      var dups = {};
      var everything = $('*');
      var ids = everything.map(function(){ return this.id; });
      $.each(ids, function(i) {
        if (this == '') return;
        dups[this] = dups[this] || 0;
        dups[this] += 1;
        if (dups[this] >= 2) console.log('duplicate id found: ' + this, everything[i]);
      });
    },

    // Reload all of the CSS in each frame.
    reloadCSS : function(win) {
      win = win || window;
      var links = $('link', win.document);
      links.each(function() {
        var link = $(this);
        var url = link.attr('href');
        if (url && (/stylesheet/i).test(link.attr('rel'))) {
          var h = url.replace(/(&|%5C?)forceReload=\d+/, '');
          link.attr('href', h+(h.indexOf('?')>=0?'&':'?')+'forceReload='+(new Date().valueOf()));
        }
      });
      $.each(win.frames, function() { $.debug.reloadCSS(this); });
    }

  }
});

