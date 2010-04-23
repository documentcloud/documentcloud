// Entity Model

// An Entity, on the client, should be the aggregate of all of the occurrences
// of a particular entity in the currently-viewed documents. To that end,
// it has an averageRelevance() over its documents()...
dc.model.PureEntity = dc.Model.extend({});

dc.model.Entity = dc.Model.extend({

  // Create a new entity from an instance(s) raw object.
  // Generally, you'll want to make 'em through Entities.addOrCreate() instead.
  constructor : function(instances) {
    var instances = _.flatten([instances]);
    var id = dc.model.Entity.generateId(instances[0]);
    this.instanceCount = instances.length;
    this.base({
      instances : instances,
      id : id,
      value : instances[0].value,
      kind : instances[0].kind
    });
  },

  // Adds a document-instance of the entity to this object.
  addInstance : function(instance) {
    this.get('instances').push(instance);
    this.instanceCount++;
    delete this._docIds;
    return instance;
  },

  // Grab the selected instances of the entity -- the entities within
  // currently selected documents.
  selectedInstances : function() {
    var docIds = Documents.selectedIds();
    return _.select(this.get('instances'), function(inst) {
      return _.include(docIds, inst.document_id);
    });
  },

  // Look up and cache the set of document_ids from the entity instances.
  documentIds : function() {
    return this._docIds = this._docIds || _.pluck(this.get('instances'), 'document_id');
  },

  // Just give us the first id that comes to mind.
  firstId : function() {
    return this.documentIds()[0];
  },

  // Return a list of all of the currently-loaded documents referencing this
  // Entity.
  documents : function() {
    return _(this.documentIds()).map(function(id){ return Documents.get(id); });
  },

  // Compute the average relevance of this Entity to the currently loaded
  // set of Documents.
  averageRelevance : function() {
    return this.totalRelevance() / this.instanceCount;
  },

  // Compute the total relevance of this Entity (entities occurring in more
  // documents will have a higher score).
  totalRelevance : function() {
    return _.inject(this.get('instances'), 0, function(sum, instance) {
      return sum + instance.relevance;
    });
  },

  // Truncate the total relevance for display.
  displayTotalRelevance : function() {
    return this.totalRelevance().toString().substring(0, 5);
  },

  // Display-ready version of the entity kind.
  displayKind : function() {
    return Inflector.capitalize(Inflector.pluralize(Inflector.spacify(this.get('kind'))));
  },

  // Display-ready version of the entity title.
  displayTitle : function() {
    return Inflector.capitalize(Inflector.spacify(this.get('kind'))) + ": " + this.get('value');
  },

  // Return the string that one would use to perform a fielded search for this
  // entity.
  toSearchQuery : function() {
    var val = this.get('value'), kind = this.get('kind');
    if (val.match(/\s/)) val = '"' + val + '"';
    return kind + ":" + val;
  },

  // Inspect.
  toString : function() {
    return 'Entity "' + this.get('instances')[0].value + '" ' + this.id;
  }

}, {

  // Generate the canonical client id for a kind, and calais hash or value pair.
  generateId : function(attributes) {
    var value = (attributes.calais_id || attributes.value).replace(/\W/g, '');
    return attributes.kind + ':' + value;
  }

});


// Entity Set

dc.model.EntitySet = dc.model.SortedSet.extend({

  model : dc.model.Entity,

  // Map of kind to display name for titles and the like.
  DISPLAY_NAME : {
    city          : 'Cities',
    country       : 'Countries',
    date          : 'Dates',
    phone         : 'Phone Numbers',
    organization  : 'Organizations',
    person        : 'People',
    place         : 'Places',
    state         : 'States',
    term          : 'Terms'
  },

  // Entities are kept sorted by totalRelevance() of each datum, across its
  // documents.
  comparator : function(m) {
    return m.get('value').toLowerCase();
  },

  // Populate the Entity set from the current documents in the client,
  // triggering a refresh when loaded.
  populate : function(callback) {
    dc.ui.spinner.show('loading');
    $.get('/documents/entities.json', {'ids[]' : Documents.getIds()}, function(resp) {
      _.each(resp.entities, function(m){ Entities.addOrCreate(m); });
      Entities.sort();
      dc.ui.spinner.hide();
      callback();
    }, 'json');
  },

  // Fetch a single entity across a set of visible documents.
  fetch : function(kind, value, callback) {
    dc.ui.spinner.show('loading');
    $.get('/documents/entity.json', {'ids[]' : Documents.getIds(), kind : kind, value : value}, function(resp) {
      callback(_.map(resp.entities, function(obj){ return new dc.model.PureEntity(obj); }));
      dc.ui.spinner.hide();
    }, 'json');
  },

  // Returns the sorted list of entities for the currently-selected documents.
  // If "ensure" is passed, return all entities when no documents are selected.
  selected : function(ensure) {
    var docIds = Documents.selectedIds();
    if (docIds.length <= 0) return ensure ? this.models() : [];
    return _(this.models()).select(function(ent){
      return _(ent.documentIds()).any(function(id){ return _(docIds).include(id); });
    });
  },

  uniqueInstancesByDocument : function(instances) {
    var seenMap = {};
    return _.select(instances, function(inst) {
      var seen = seenMap[inst.document_id];
      seenMap[inst.document_id] = true;
      return !seen;
    });
  },

  addOrCreate : function(obj) {
    var id = dc.model.Entity.generateId(obj);
    var ent = this.get(id);
    return ent ? ent.addInstance(obj) : this.add(new dc.model.Entity(obj));
  },

  toString : function() {
    return 'Entity ' + this.base();
  }

});

window.Entities = new dc.model.EntitySet();