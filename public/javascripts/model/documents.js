// Document Model

dc.model.Document = dc.Model.extend({

  constructor : function(attributes) {
    this.base(attributes);
    this.notes = new dc.model.NoteSet();
    this.notes.resource = 'documents/' + this.id + '/annotations';
    this.pageEntities = new dc.model.EntitySet();
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

  pageThumbnailURL : function(page) {
    return this.get('page_image_url').replace('{size}', 'thumbnail').replace('{page}', page);
  },

  // Is the document editable by the current account?
  allowedToEdit : function(message) {
    message = message || "You don't have permission to edit \"" + this.get('title') + "\".";
    var acc = Accounts.current();
    if (this.get('account_id') == acc.id) return true;
    if (this.get('organization_id') == acc.get('organization_id') && acc.isAdmin()) return true;
    if (_.include(acc.get('shared_document_ids'), this.id)) return true;
    dc.ui.Dialog.alert(message);
    return false;
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

  // Return a list of the document's entities. Think about caching this on the
  // document by binding to Entities, instead of on-the-fly.
  entities : function() {
    var docId = this.id;
    return _.select(Entities.models(), function(m) {
      return _.any(m.get('instances'), function(i){
        return i.document_id == docId;
      });
    });
  },

  uniquePageEntityValues : function() {
    return _.uniq(_.map(this.pageEntities.models(), function(m){ return m.get('value'); }));
  },

  isPending : function() {
    return this.get('access') == dc.access.PENDING;
  },

  isPublic : function() {
    return this.get('access') == dc.access.PUBLIC;
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
  model    : dc.model.Document,

  POLL_INTERVAL : 10000, // 10 seconds.

  constructor : function(options) {
    this.base(options);
    this._polling = false;
    _.bindAll(this, 'poll', 'downloadSelectedViewers', 'downloadSelectedPDF', 'downloadSelectedFullText');
  },

  comparator : function(doc) {
    return doc.get('index');
  },

  pending : function() {
    return _.select(this.models(), function(doc){ return doc.isPending(); });
  },

  allowedToEditSelected : function(message) {
    return !_.any(this.selected(), function(doc) { return !doc.allowedToEdit(message); });
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

  // We override `add` to listen for uploading documents, and to start polling
  // for changes.
  add : function(model, silent) {
    this.base(model, silent);
    this._checkForPending();
  },

  // We override `refresh` to cancel the polling action if the current set
  // has no pending documents.
  refresh : function(models, silent) {
    this.base(models, silent);
    if (!this.pending().length) this.stopPolling();
  },

  _checkForPending : function() {
    if (this._polling) return false;
    if (!this.pending().length) return false;
    this.startPolling();
  }

});

// The main set of Documents, used by the search tab.
dc.model.DocumentSet.implement(dc.model.SortedSet);
dc.model.DocumentSet.implement(dc.model.SelectableSet);
window.Documents = new dc.model.DocumentSet();
