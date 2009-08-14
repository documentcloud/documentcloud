dc.model.MetadataSet = dc.model.SortedSet.extend({
  
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

window.Metadata = new dc.model.MetadataSet(
  function(a, b) {
    var aRel = a.totalRelevance(), bRel = b.totalRelevance();
    return aRel < bRel ? 1 : (bRel < aRel ? -1 : 0);
  }
);