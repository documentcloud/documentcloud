dc.model.Metadatum = dc.Model.extend({
  
  document : function() {
    return Documents.get(this.get('document_id'));
  },
  
  toString : function() {
    return 'Metadatum ' + this.id;
  }
  
});