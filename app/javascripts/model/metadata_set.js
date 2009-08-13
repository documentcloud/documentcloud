dc.model.MetadataSet = dc.Set.extend({
  
  toString : function() {
    return 'Metadata ' + this.base();
  }
  
});

window.Metadata = new dc.model.MetadataSet();