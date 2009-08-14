dc.model.Document = dc.Model.extend({
  
  // Return a list of the document's metadata. Think about caching this on the
  // document by binding to Metadata, instead of on-the-fly.
  metadata : function() {
    var docId = this.id;
    return _.select(Metadata.values(), function(m) {
      return _.any(m.get('instances'), function(i){ 
        return i.document_id == docId; 
      });
    });
  },
  
  toString : function() {
    return 'Document ' + this.id + ' "' + this.get('title') + '"';
  }
  
});