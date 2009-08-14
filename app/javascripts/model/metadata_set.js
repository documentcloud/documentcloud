dc.model.MetadataSet = dc.Set.extend({
  
  constructor : function() {
    this.base();
    this._byType = {};
    this._byCalaisHash = {};
  },
  
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