dc.model.Metadatum = dc.Model.extend({
  
  constructor : function(instances) {
    var instances = _.flatten([instances]);
    var id = dc.model.Metadatum.generateId(instances[0]);
    this._size = instances.length;
    this.base({instances : instances, id : id});
  },
  
  addInstance : function(instance) {
    this.set({instances : this.get('instances').concat(instance)});
    this._size++;
    return instance;
  },
  
  documents : function() {
    return _.map(this.get('instances'), function(instance) {
      return Documents.get(instance.document_id);
    });
  },
  
  averageRelevance : function() {
    return this.totalRelevance() / this._size;
  },
  
  totalRelevance : function() {
    return _.inject(this.get('instances'), 0, function(sum, instance) {
      return sum + instance.relevance;
    });
  },
  
  toString : function() {
    return 'Metadatum ' + this.id;
  }
  
}, {
  
  // Generate the canonical client id for a type, and calais hash or value pair.
  generateId : function(attributes) {
    return attributes.type + ':' + (attributes.calais_hash || attributes.value);
  }
  
});