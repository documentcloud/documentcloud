dc.model.Document = dc.Model.extend({
  
  toString : function() {
    return 'Document ' + this.id + ' "' + this.get('title') + '"';
  }
  
});