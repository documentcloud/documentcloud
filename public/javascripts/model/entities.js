// Entity Model

dc.model.Entity = Backbone.Model.extend({

  // Lazily split and cache the serialized occurrences (they won't change).
  occurrences : function() {
    if (!this._occurrences) {
      this._occurrences = _.map(this.get('occurrences').split(','), function(pair) {
        return pair.split(':');
      });
      this.occurrenceCount = this._occurrences.length;
    }
    return this._occurrences;
  }

}, {

  // Map of kind to display name for titles and the like.
  DISPLAY_NAME : {
    city          : 'Cities',
    country       : 'Countries',
    date          : 'Dates',
    phone         : 'Phone Numbers',
    email         : 'Email Addresses',
    organization  : 'Organizations',
    person        : 'People',
    place         : 'Places',
    state         : 'States',
    term          : 'Terms'
  },

  // When rendering entities in a list, use this order:
  ORDER : ['person', 'organization', 'place', 'term', 'email', 'phone', 'city', 'state', 'country'],

  // Fetch a single entity across a set of visible documents.
  fetch : function(kind, value, callback) {
    dc.ui.spinner.show();
    $.get('/documents/entity.json', {'ids[]' : Documents.pluck('id'), kind : kind, value : value}, function(resp) {
      callback(_.map(resp.entities, function(obj){ return new dc.model.Entity(obj); }));
      dc.ui.spinner.hide();
    }, 'json');
  }

});

// Entity Set

dc.model.EntitySet = Backbone.Collection.extend({

  model : dc.model.Entity,

  // comparator : function(entity) {
  //   var pages = _.pluck(entity.get('excerpts'), 'page_number');
  //   return Math.min.apply(Math, pages);
  // }

  index : function() {
    if (!this._index) {
      var index = this._index = _.groupBy(this.models, function(e){ return e.attributes.kind; });
      _.each(index, function(list, kind) {
        index[kind] = _.sortBy(list, function(item){ return -item.occurrences().length; });
      });
    }
    return this._index;
  },

  sumOccurrences : function() {
    this.index();
    var sum = 0, i = this.models.length;
    while (i--) sum += this.models[i].occurrenceCount;
    return sum;
  }

}, {

  populateDocuments: function(docs, callback) {
    var missing = _.select(docs, function(doc){ return !doc.entities.loaded; });
    if (!missing.length) return callback && callback();
    $.get('/documents/entities.json', {'ids[]' : _.pluck(missing, 'id')}, function(resp) {
      var entities = _.groupBy(resp.entities, 'document_id');
      _.each(entities, function(list, docId) {
        var collection = Documents.get(docId).entities;
        collection.loaded = true;
        collection.reset(list);
      });
      callback && callback();
    }, 'json');
  }

});

window.EntityDates = new dc.model.EntitySet();

EntityDates.comparator = function(entity) {
  return entity.get('date');
};
