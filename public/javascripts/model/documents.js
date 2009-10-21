// Document Model

dc.model.Document = dc.Model.extend({
  
  constructor : function(attributes) {
    this.base(attributes);
    this.s3 = !(RAILS_ENV == 'development');
  },
  
  // Return a list of the document's metadata. Think about caching this on the
  // document by binding to Metadata, instead of on-the-fly.
  metadata : function() {
    var docId = this.id;
    return _.select(Metadata.models(), function(m) {
      return _.any(m.get('instances'), function(i){ 
        return i.document_id == docId; 
      });
    });
  },
  
  thumbnailURL : function() {
    if (!this.get('thumbnail')) return null;
    return this.s3 ? this.get('thumbnail') : '/documents/thumbnail/' + this.id;
  },
  
  pdfURL : function() {
    return this.s3 ? this.get('pdf') : '/documents/' + this.id + '.pdf';
  },
  
  textURL : function() {
    return '/documents/' + this.id + '.txt';
  },
  
  // Inspect.
  toString : function() {
    return 'Document ' + this.id + ' "' + this.get('title') + '"';
  }
  
});


// Document Set

dc.model.DocumentSet = dc.model.RESTfulSet.extend({
  
  resource : 'documents',
  
  selected : function() {
    return _.select(this.models(), function(m){ return m.selected; });
  },
  
  selectedIds : function() {
    return _.pluck(this.selected(), 'id');
  }
  
});

// The main set of Documents, used by the search tab.
window.Documents = new dc.model.DocumentSet();

// The set of documents that is used to look at a particular label.
dc.app.LabeledDocuments = new dc.model.DocumentSet();
