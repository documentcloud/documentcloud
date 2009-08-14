// A Metadatum, on the client, should be the aggregate of all of the occurrences
// of a particular entity in the currently-viewed documents. To that end,
// it has an averageRelevance() over its documents()...
dc.model.Metadatum = dc.Model.extend({
  
  // Create a new metadatum from an instance(s) raw object.
  // Generally, you'll want to make 'em through Metadata.addOrCreate() instead.
  constructor : function(instances) {
    var instances = _.flatten([instances]);
    var id = dc.model.Metadatum.generateId(instances[0]);
    this._size = instances.length;
    this.base({
      instances : instances, 
      id : id, 
      value : instances[0].value,
      type : instances[0].type
    });
  },
  
  // Adds a document-instance of the metadatum to this object.
  addInstance : function(instance) {
    this.set({instances : this.get('instances').concat(instance)});
    this._size++;
    return instance;
  },
  
  // Return a list of all of the currently-loaded documents referencing this
  // Metadatum.
  documents : function() {
    return _.map(this.get('instances'), function(instance) {
      return Documents.get(instance.document_id);
    });
  },
  
  // Compute the average relevance of this Metadatum to the currently loaded
  // set of Documents. Maintains 4 significant digits of accuracy.
  averageRelevance : function() {
    return Math.round((this.totalRelevance() / this._size) * 1000) / 1000;
  },
  
  // Compute the total relevance of this Metadatum (metadata occurring in more
  // documents will have a higher score).
  totalRelevance : function() {
    return _.inject(this.get('instances'), 0, function(sum, instance) {
      return sum + instance.relevance;
    });
  },
  
  // Inspect.
  toString : function() {
    return 'Metadatum "' + this.get('instances')[0].value + '" ' + this.id;
  }
  
}, {
  
  // Generate the canonical client id for a type, and calais hash or value pair.
  generateId : function(attributes) {
    return attributes.type + ':' + (attributes.calais_hash || attributes.value);
  }
  
});