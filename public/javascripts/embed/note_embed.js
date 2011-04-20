(function() {
  
  window.dc = window.dc || {};
  dc.note_embed = dc.note_embed || {};
  var notes = dc.note_embed.notes = dc.note_embed.notes || {};
  
  var _ = dc._        = window._.noConflict();
  var $ = dc.jQuery   = window.jQuery.noConflict(true);
  
  dc.note_embed.load = function(embedUrl, opts) {
    console.log(['load', embedUrl, opts]);
    var id = opts.note_id;
    notes[id] = notes[id] || {};
    notes[id].options = opts;

    var urlParams = '/documents/' + encodeURIComponent(opts.document_id) +
                    '/note/'      + encodeURIComponent(opts.note_id) + '.js';
    var params = '?callback=dc.note_embed.callback';
    $.getScript(embedUrl + urlParams + params);
  };
  
  dc.note_embed.callback = function(response) {
    var id = response.annotation.id;
    var note = new dc.note_embed.noteModel(response.annotation);
    console.log(['response', id, response, notes[id].options, note]);
    $('#DC-note-' + id).html(JST['note_embed']({note : note}));
  };
  
  dc.note_embed.noteModel = function(json) {
    this.attributes = {};
    _.each(json, _.bind(function(value, key) {
      this.attributes[key] = value;
    }, this));
  };
  
  dc.note_embed.noteModel.prototype = {
    
    get : function(key) {
      return this.attributes[key];
    },
    
    option : function(key) {
      return dc.note_embed.notes[this.get('id')].options[key];
    },
    
    imageUrl : function() {
      return this._imageUrl = this._imageUrl ||
        this.option('image_url').replace('{size}', 'normal').replace('{page}', this.get('page'));
    },

    coordinates : function() {
      if (this._coordinates) return this._coordinates;
      var loc = this.get('location');
      if (!loc) return null;
      var css = _.map(loc.image.split(','), function(num){ return parseInt(num, 10); });
      return this._coordinates = {
        top:    css[0],
        left:   css[3],
        right:  css[1],
        height: css[2] - css[0],
        width:  css[3] - css[1]
      };
    }
  };
  
})();