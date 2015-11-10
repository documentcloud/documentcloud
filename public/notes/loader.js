

(function() {
  // If the note embed is already loaded, don't repeat the process.
  if (window.dc) { if (window.dc.noteEmbedLoaded) { return; } }

  window.dc = window.dc || {};
  window.dc.recordHit = "//dev.dcloud.org/pixel.gif";

  var loadCSS = function(url, media) {
    var link   = document.createElement('link');
    link.rel   = 'stylesheet';
    link.type  = 'text/css';
    link.media = media || 'screen';
    link.href  = url;
    var head   = document.getElementsByTagName('head')[0];
    head.appendChild(link);
  };

  /*@cc_on
  /*@if (@_jscript_version < 5.8)
    loadCSS("//dev.dcloud.org/note_embed/note_embed.css");
  @else @*/
    loadCSS("//dev.dcloud.org/note_embed/note_embed-datauri.css");
  /*@end
  @*/

  // Record the fact that the note embed is loaded.
  dc.noteEmbedLoaded = true;

  // Request the embed JavaScript.
  document.write('<script type="text/javascript" src="//dev.dcloud.org/note_embed/note_embed.js"></scr' + 'ipt>');
})();
