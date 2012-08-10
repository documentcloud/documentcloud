(function() {
  
  window.dc = window.dc || {};
  dc.embed = dc.embed || {};
  var notes = dc.embed.notes = dc.embed.notes || {};
  
  var _ = dc._        = window._.noConflict();
  var $ = dc.jQuery   = window.jQuery.noConflict(true);
  
  dc.embed.loadNote = function(embedUrl, opts) {
    var id = parseInt(embedUrl.match(/(\d+).js$/)[1], 10);
    notes[id] = notes[id] || new dc.embed.noteModel(opts);
    $.getScript(embedUrl);
    dc.embed.pingRemoteUrl('note', id);
  };
  
  dc.embed.noteCallback = function(response) {
    var id   = response.id;
    var note = dc.embed.notes[id];
    note.attributes = response;
    note.render();
    if (note.options && note.options.afterLoad) note.options.afterLoad(note);
  };
  
  dc.embed.noteModel = function(opts) {
    this.options = opts || {};
  };
  
  dc.embed.noteModel.prototype = {
    render : function(selector) {
      var options    = this.options;
      var container  = selector || options.container || '#DC-note-' + this.get('id');
      var $container = $(container);
      var containerWidth = $container.width();

      $container.html(JST['note_embed']({note : this}));
      if (containerWidth < 700) this.center($container, containerWidth);
      return $container;
    },
    
    get : function(key) {
      return this.attributes[key];
    },
    
    option : function(key) {
      return dc.embed.notes[this.get('id')].options[key];
    },
    
    imageUrl : function() {
      return (this._imageUrl = this._imageUrl ||
        this.get('image_url').replace('{size}', 'normal').replace('{page}', this.get('page')));
    },

    coordinates : function() {
      if (this._coordinates) return this._coordinates;
      var loc = this.get('location');
      if (!loc) return null;
      var css = _.map(loc.image.split(','), function(num){ return parseInt(num, 10); });
      return (this._coordinates = {
        top:    css[0],
        left:   css[3],
        right:  css[1],
        height: css[2] - css[0],
        width:  css[1] - css[3]
      });
    },
    
    center : function($container) {
      var $excerpt       = $('.DC-note-excerpt', $container);
      var coords         = this._coordinates;
      if (!coords) return;
      var annoCenter     = coords.left + (coords.width / 2);
      var viewportWidth  = $excerpt.closest('.DC-note-excerpt-wrap').width();
      var viewportCenter = viewportWidth / 2;

      if (coords.left + coords.width > viewportWidth) {
        if (coords.width > viewportWidth) {
          $excerpt.css('left', -1 * coords.left);
        } else {
          $excerpt.css('left', viewportCenter - annoCenter);
        }
      }
    },
    
    viewerUrl : function() {
      var suffix = '#document/p' + this.get('page') + '/a' + this.get('id');
      return this.get('published_url') + suffix;
    }
    
  };
  
  dc.embed.pingRemoteUrl = function(type, id) {
    var loc = window.location;
    var url = loc.protocol + '//' + loc.host + loc.pathname;
    if (url.match(/^file:/)) return false;
    url = url.replace(/[\/]+$/, '');
    var hitUrl = dc.recordHit;
    var key    = encodeURIComponent(type + ':' + id + ':' + url);
    $(document).ready( function(){ $(document.body).append('<img alt="" width="1" height="1" src="' + hitUrl + '?key=' + key + '" />'); });
  };
  
})();
