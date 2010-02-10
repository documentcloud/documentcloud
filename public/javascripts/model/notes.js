// Note Model

dc.model.Note = dc.Model.extend({

  document : function() {
    return this._document = this._document || Documents.get(this.get('document_id'));
  },

  imageUrl : function() {
    return this._imageUrl = this._imageUrl ||
      this.document().get('page_image_url').replace('{size}', 'normal').replace('{page}', this.get('page'));
  },

  coordinates : function() {
    if (this._coordinates) return this._coordinates;
    var serialized = this.get('location').image;
    var css = _.map(serialized.split(','), function(num){ return parseInt(num, 10); });
    return this._coordinates = {
      top:    css[0],
      left:   css[3],
      height: css[2] - css[0],
      width:  css[3] - css[1]
    };
  }

});

// Note Set

dc.model.NoteSet = dc.model.RESTfulSet.extend({

  resource : 'notes',

  comparator : function(note) {
    return note.get('page');
  }

});

dc.model.NoteSet.implement(dc.model.SortedSet);
