// Document Model

dc.model.Document = dc.Model.extend({

  constructor : function(attributes) {
    this.base(attributes);
  },

  // The import process will take care of this in the future, but the inline
  // version of the summary has all runs of whitespace squeezed out.
  inlineSummary : function() {
    var summ = this.get('summary');
    return summ ? summ.replace(/\s+/g, ' ') : '';
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

  // Inspect.
  toString : function() {
    return 'Document ' + this.id + ' "' + this.get('title') + '"';
  }

});


// Document Set

dc.model.DocumentSet = dc.model.RESTfulSet.extend({

  resource : 'documents',

  SELECTION_CHANGED : 'documents:selection_changed',

  constructor : function(options) {
    this.base(options);
    _.bindAll('downloadSelectedViewers', 'downloadSelectedPDF', 'downloadSelectedFullText', this);
  },

  selected : function() {
    return _.select(this.models(), function(m){ return m.get('selected'); });
  },

  selectedIds : function() {
    return _.pluck(this.selected(), 'id');
  },

  countSelected : function() {
    return this.selected().length;
  },

  downloadSelectedViewers : function() {
    dc.app.download('/download/' + this.selectedIds().join('/') + '/document_viewer.zip');
  },

  downloadSelectedPDF : function() {
    if (this.countSelected() <= 1) return window.open(this.selected()[0].get('pdf_url'));
    dc.app.download('/download/' + this.selectedIds().join('/') + '/document_pdfs.zip');
  },

  downloadSelectedFullText : function() {
    if (this.countSelected() <= 1) return window.open(this.selected()[0].get('full_text_url'));
    dc.app.download('/download/' + this.selectedIds().join('/') + '/document_text.zip');
  },

  // We override "_onModelEvent" to fire selection changed events when documents
  // change their selected state.
  _onModelEvent : function(e, model) {
    this.base(e, model);
    var fire = (e == dc.Model.CHANGED && model.hasChanged('selected'));
    if (fire) _.defer(_(this.fire).bind(this, this.SELECTION_CHANGED, this));
  }

});

// The main set of Documents, used by the search tab.
window.Documents = new dc.model.DocumentSet();

// The set of documents that is used to look at a particular label.
dc.app.LabeledDocuments = new dc.model.DocumentSet();
