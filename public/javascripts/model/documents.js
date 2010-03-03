// Document Model

dc.model.Document = dc.Model.extend({

  constructor : function(attributes) {
    this.base(attributes);
    this.notes = new dc.model.NoteSet();
    this.notes.resource = 'documents/' + this.id + '/annotations';
  },

  openViewer : function() {
    if (this.checkBusy()) return;
    window.open(this.get('document_viewer_url'));
  },

  openText : function() {
    if (this.checkBusy()) return;
    window.open(this.get('full_text_url'));
  },

  openPDF : function() {
    if (this.checkBusy()) return;
    window.open(this.get('pdf_url'));
  },

  checkBusy : function() {
    if (!(this.get('access') == dc.access.PENDING)) return false;
    dc.ui.Dialog.alert('"' + this.get('title') + '" is still being processed. Please wait for it to finish.');
    return true;
  },

  // For display, show either the highlighted search results, or the description,
  // if no highlights are available.
  // The import process will take care of this in the future, but the inline
  // version of the description has all runs of whitespace squeezed out.
  displayDescription : function() {
    var text = this.get('highlight') || this.get('description');
    return text ? text.replace(/\s+/g, ' ') : '';
  },

  thumbnailURL : function() {
    return this.get('access') == dc.access.PENDING ?
      '/images/embed/documents/processing.png' :
      this.get('thumbnail_url');
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

  isPending : function() {
    return this.get('access') == dc.access.PENDING;
  },

  decrementNotes : function() {
    var count = this.get('annotation_count');
    if (count <= 0) return false;
    this.set({annotation_count : count - 1});
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

  POLL_INTERVAL : 10000, // 10 seconds.

  constructor : function(options) {
    this.base(options);
    this._polling = false;
    _.bindAll(this, 'poll', 'downloadSelectedViewers', 'downloadSelectedPDF', 'downloadSelectedFullText');
  },

  selectAll : function() {
    _.each(this.models(), function(m){ m.set({selected : true}); });
  },

  deselectAll : function() {
    _.each(this.models(), function(m){ m.set({selected : false}); });
  },

  selected : function() {
    return _.select(this.models(), function(m){ return m.get('selected'); });
  },

  selectedIds : function() {
    return _.pluck(this.selected(), 'id');
  },

  pending : function() {
    return _.select(this.models(), function(doc){ return doc.isPending(); });
  },

  countSelected : function() {
    return this.selected().length;
  },

  downloadSelectedViewers : function() {
    dc.app.download('/download/' + this.selectedIds().join('/') + '/document_viewer.zip');
  },

  downloadSelectedPDF : function() {
    if (this.countSelected() <= 1) return this.selected()[0].openPDF();
    dc.app.download('/download/' + this.selectedIds().join('/') + '/document_pdfs.zip');
  },

  downloadSelectedFullText : function() {
    if (this.countSelected() <= 1) return this.selected()[0].openText();
    dc.app.download('/download/' + this.selectedIds().join('/') + '/document_text.zip');
  },

  startPolling : function() {
    this._polling = setInterval(this.poll, this.POLL_INTERVAL);
  },

  stopPolling : function() {
    clearInterval(this._polling);
    this._polling = null;
  },

  poll : function() {
    var ids = _.pluck(this.pending(), 'id');
    $.get('/documents/status.json', {'ids[]' : ids}, _.bind(function(resp) {
      _.each(resp.documents, function(json) {
        var doc = Documents.get(json.id);
        if (doc && doc.get('access') != json.access) doc.set(json);
      });
      if (!this.pending().length) this.stopPolling();
    }, this), 'json');
  },

  // We override add to listen for uploading documents, and to start polling
  // for changes.
  add : function(model, silent) {
    this.base(model, silent);
    this._checkForPending();
  },

  _checkForPending : function() {
    if (this._polling) return false;
    if (!this.pending().length) return false;
    this.startPolling();
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
