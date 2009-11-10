// Metadata Model

// A Metadatum, on the client, should be the aggregate of all of the occurrences
// of a particular entity in the currently-viewed documents. To that end,
// it has an averageRelevance() over its documents()...
dc.model.Metadatum = dc.Model.extend({

  // Create a new metadatum from an instance(s) raw object.
  // Generally, you'll want to make 'em through Metadata.addOrCreate() instead.
  constructor : function(instances) {
    var instances = _.flatten([instances]);
    var id = dc.model.Metadatum.generateId(instances[0]);
    this.instanceCount = instances.length;
    this.base({
      instances : instances,
      id : id,
      value : instances[0].value,
      kind : instances[0].kind
    });
  },

  // Adds a document-instance of the metadatum to this object.
  addInstance : function(instance) {
    this.get('instances').push(instance);
    this.instanceCount++;
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
  // set of Documents.
  averageRelevance : function() {
    return this.totalRelevance() / this.instanceCount;
  },

  // Compute the total relevance of this Metadatum (metadata occurring in more
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

  // Display-ready version of the metadata kind.
  displayKind : function() {
    return Metadata.KIND_MAP[this.get('kind')];
  },

  // Return the string that one would use to perform a fielded search for this
  // metadatum.
  toSearchQuery : function() {
    var val = this.get('value'), kind = this.get('kind');
    if (val.match(/\s/)) val = '"' + val + '"';
    return kind + ":" + val;
  },

  // Inspect.
  toString : function() {
    return 'Metadatum "' + this.get('instances')[0].value + '" ' + this.id;
  }

}, {

  // Generate the canonical client id for a kind, and calais hash or value pair.
  generateId : function(attributes) {
    var value = (attributes.calais_id || attributes.value).replace(/\W/g, '');
    return attributes.kind + ':' + value;
  }

});


// Metadata Set

dc.model.MetadataSet = dc.model.SortedSet.extend({

  // Mapping from our white listed metadata kinds to their display names.
  // Keep this list in sync with the mapping in metadatum.rb, please.
  KIND_MAP : {
    category : "Categories", city : 'Cities', company : 'Companies', continent : 'Contintents',
    country : 'Countries', email_address : 'Email Addresses', facility : 'Places',
    holiday : "Holidays", industry_term : "Terms", natural_feature : "Landmarks",
    organization : "Organizations", person : "People", position : "Positions",
    product : "Products", province_or_state : "States", published_medium : "Publications",
    region : "Regions", technology : "Technologies", url : "Web Pages"
  },

  // Metadata are kept sorted by totalRelevance() of each datum, across its
  // documents.
  comparator : function(m) {
    return m.totalRelevance();
  },

  // TODO: ... extend this to re-sort addInstance'd metas.
  addOrCreate : function(obj) {
    var id = dc.model.Metadatum.generateId(obj);
    var meta = this.get(id);
    return meta ? meta.addInstance(obj) : this.add(new dc.model.Metadatum(obj));
  },

  toString : function() {
    return 'Metadata ' + this.base();
  }

});

window.Metadata = new dc.model.MetadataSet();