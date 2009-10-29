// Label Model

dc.model.Label = dc.Model.extend({
  
  resource : 'labels',
  
  constructor : function(options) {
    this.base(options);
    _.bindAll('addSelectedDocuments', this);
  },
  
  documentIds : function() {
    if (!this.get('document_ids')) return [];
    return this.get('document_ids').split(',');
  },
  
  addSelectedDocuments : function() {
    var newIds = _.uniq(this.documentIds().concat(Documents.selectedIds()));
    Labels.update(this, {document_ids : newIds.join(',')});
  },
  
  // Return the title of this label as a search parameter.
  toSearchParam : function() {
    var titlePart = this.get('title');
    if (titlePart.match(/\s/)) titlePart = '"' + titlePart + '"';
    return 'label: ' + titlePart;
  },
  
  sortKey : function() {
    this.get('title');
  }
  
});


// Label Set

dc.model.LabelSet = dc.model.RESTfulSet.extend({
  
  resource : 'labels',
  
  // Find a label by title.
  find : function(title) {
    return _.detect(this.models(), function(m){ return m.get('title') == title; });
  },
  
  // Find all labels starting with a given prefix, for autocompletion.
  startingWith : function(prefix) {
    var matcher = new RegExp('^' + prefix);
    return _.select(this.models(), function(m){ return !!m.get('title').match(matcher); });
  }
  
});

window.Labels = new dc.model.LabelSet();
