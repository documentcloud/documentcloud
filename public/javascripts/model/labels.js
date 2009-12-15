// Label Model

dc.model.Label = dc.Model.extend({

  resource : 'labels',

  viewClass : 'Label',

  documentIds : function() {
    if (!this.get('document_ids')) return [];
    return this.get('document_ids').split(',');
  },

  // Return the title of this label as a search parameter.
  toSearchParam : function() {
    var titlePart = this.get('title');
    if (titlePart.match(/\s/)) titlePart = '"' + titlePart + '"';
    return 'label: ' + titlePart;
  },

  sortKey : function() {
    return this.get('title').toLowerCase();
  }

});


// Label Set

dc.model.LabelSet = dc.model.RESTfulSet.extend({

  resource : 'labels',

  comparator : function(m) {
    return m.get('title');
  },

  addSelectedDocuments : function(label) {
    var newIds = _.uniq(label.documentIds().concat(Documents.selectedIds()));
    this.update(label, {document_ids : newIds.join(',')});
  },

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

dc.model.LabelSet.implement(dc.model.SortedSet);
window.Labels = new dc.model.LabelSet();
