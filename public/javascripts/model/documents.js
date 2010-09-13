// Document Model

dc.model.Document = dc.Model.extend({

  constructor : function(attributes) {
    attributes.selected = false;
    attributes.selectable = true;
    this.base(attributes);
    this.notes = new dc.model.NoteSet();
    this.notes.resource = 'documents/' + this.id + '/annotations';
    this.pageEntities = new dc.model.EntitySet();
  },

  // Generate the canonical URL for opening this document, over SSL if we're
  // currently secured.
  url : function() {
    var base = this.get('document_viewer_url').replace(/^http:/, '');
    return window.location.protocol + base;
  },

  // Generate the canonical id for this document.
  canonicalId : function() {
    return this.id + '-' + this.get('slug');
  },

  openViewer : function() {
    if (this.checkBusy()) return;
    window.open(this.url());
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

  allowedToEdit : function() {
    return Accounts.current().checkAllowedToEdit(this);
  },

  // Is the document editable by the current account?
  checkAllowedToEdit : function(message) {
    message = message || "You don't have permission to edit \"" + this.get('title') + "\".";
    if (this.allowedToEdit()) return true;
    dc.ui.Dialog.alert(message);
    return false;
  },

  checkBusy : function() {
    if (!(this.get('access') == dc.access.PENDING)) return false;
    dc.ui.Dialog.alert('"' + this.get('title') + '" is still being processed. Please wait for it to finish.');
    return true;
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

  isPublished : function() {
    return this.isPublic() && (this.get('remote_url') || this.get('detected_remote_url'));
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

  EMBED_FORBIDDEN : "At this stage in the beta, you may only embed documents you've uploaded yourself.",

  POLL_INTERVAL : 10000, // 10 seconds.

  constructor : function(options) {
    this.base(options);
    this._polling = false;
    _.bindAll(this, 'poll', 'downloadViewers', 'downloadSelectedPDF', 'downloadSelectedFullText', '_onModelChanged');
    this.bind('model:changed', this._onModelChanged);
  },

  comparator : function(doc) {
    return doc.get('index');
  },

  pending : function() {
    return _.select(this.models(), function(doc){ return doc.isPending(); });
  },

  // Given a list of documents and an attribute, return the value of the
  // attribute if identical, or null if divergent.
  sharedAttribute : function(docs, attr) {
    var attrs = _.uniq(_.map(docs, function(doc){ return doc.get(attr); }));
    return attrs.length > 1 ? false : attrs[0];
  },

  allowedToEdit : function(docs, message) {
    return !_.any(docs, function(doc) { return !doc.checkAllowedToEdit(message); });
  },

  // Given a clicked document, and the current selected set, determine which
  // documents are chosen.
  chosen : function(doc) {
    var docs = this.selected();
    docs = !doc || _.include(docs, doc) ? docs : [doc];
    if (_.any(docs, function(doc){ return doc.checkBusy(); })) return [];
    return docs;
  },

  downloadViewers : function(docs) {
    var ids = _.map(docs, function(doc){ return doc.id; });
    var dialog = dc.ui.Dialog.progress('Preparing ' + Inflector.pluralize('document', ids.length) + ' for download...');
    dc.app.download('/download/' + ids.join('/') + '/document_viewer.zip', function() {
      dialog.close();
    });
  },

  downloadSelectedPDF : function() {
    if (this.selectedCount <= 1) return this.selected()[0].openPDF();
    dc.app.download('/download/' + this.selectedIds().join('/') + '/document_pdfs.zip');
  },

  downloadSelectedFullText : function() {
    if (this.selectedCount <= 1) return this.selected()[0].openText();
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

  // Destroy the currently selected documents, after asking for confirmation.
  verifyDestroy : function(docs) {
    if (!this.allowedToEdit(docs)) return;
    var message = 'Really delete ' + docs.length + ' ' + Inflector.pluralize('document', docs.length) + '?';
    dc.ui.Dialog.confirm(message, _.bind(function() {
      _(docs).each(function(doc){ Documents.destroy(doc); });
      Projects.removeDocuments(docs);
      return true;
    }, this));
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
    this._resetSelection();
    if (!this.pending().length) this.stopPolling();
    this.base(models, silent);
  },

  // When one of our models has changed, if it has changed its access level
  // to pending, start polling.
  _onModelChanged : function(e, doc) {
    if (doc.hasChanged('access') && doc.isPending()) this._checkForPending();
  },

  _checkForPending : function() {
    if (this._polling) return false;
    if (!this.pending().length) return false;
    this.startPolling();
  }

});

dc.model.DocumentSet.implement(dc.model.SortedSet);
dc.model.DocumentSet.implement(dc.model.SelectableSet);

// The main sets of Documents, used by the search tab, and the publish tab.
window.Documents          = new dc.model.DocumentSet();
window.PublishDocuments   = new dc.model.DocumentSet();
