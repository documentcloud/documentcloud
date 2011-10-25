// Entity Model

dc.model.Entity = Backbone.Model.extend({

  // Dimensions for bucketing the occurrences.
  DIMS: {
    height: 19,
    bucket: 3,
    min:    2,
    margin: 1
  },

  // Lazily split and cache the serialized occurrences (they won't change).
  occurrences : function() {
    if (!this._occurrences) {
      this._occurrences = _.map(this.get('occurrences').split(','), function(pair) {
        return pair.split(':');
      });
      this.occurrenceCount = this._occurrences.length;
    }
    return this._occurrences;
  },

  // Chunk the occurrences of this entity in the document into fixed-size boxes
  buckets : function(width) {
    var doc         = Documents.get(this.get('document_id'));
    var max         = doc.get('character_count');
    var numBuckets  = Math.floor(width / (this.DIMS.bucket + this.DIMS.margin));
    var buckets     = [];
    var maxOcc      = 5; // Even if the overall entity counts are low...

    var location = function(character) {
      return Math.floor(character / (max / numBuckets)) - 1;
    };

    for (var i = 0, l = this.occurrences().length; i < l; i++) {
      var occ = this.occurrences()[i];
      if (occ[0] > max) console.log('uh oh, ', occ[0], ' is more than ', max);
      var loc = location(occ[0]);
      if (!buckets[loc]) {
        buckets[loc] = {height: 0, occurrence: occ.join(':')};
      }
      var val = buckets[loc].height += 1;
      if (maxOcc < val) maxOcc = val;
    }

    var heightPer = this.DIMS.height / maxOcc;

    for (var i = 0, l = buckets.length; i < l; i++) {
      var bucket = buckets[i];
      if (bucket) {
        // Here we round to the nearest odd integer...
        bucket.height = (Math.round(((heightPer * bucket.height) - 1) / 2) * 2 + 1) + this.DIMS.min;
      }
    }

    return buckets;
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

  PER_PAGE: 10,

  // When rendering entities in a list, use this order:
  ORDER : ['person', 'organization', 'place', 'term', 'email', 'phone', 'city', 'state', 'country'],

  // When rendering entities in a sparkline, use this order:
  SPARK_ORDER: ['person', 'organization', 'place', 'term'],

  // Fetch a single entity across a set of visible documents.
  fetch : function(kind, value, callback) {
    this._fetch(Documents.pluck('id'), {kind: kind, value: value}, callback);
  },

  // Fetch a single entity for a single document, by id.
  fetchId : function(docId, entityId, callback) {
    this._fetch([docId], {entity_id : entityId}, callback);
  },

  _fetch : function(ids, options, callback) {
    dc.ui.spinner.show();
    var data = _.extend({'ids[]': ids}, options);
    $.get('/documents/entity.json', data, function(resp) {
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
        index[kind] = _.sortBy(list, function(item) {
          return -item.occurrences().length;
        });
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
