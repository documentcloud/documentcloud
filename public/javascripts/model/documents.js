// Document Model

dc.model.Document = Backbone.Model.extend({

  constructor : function(attrs) {
    attrs.selected = false;
    attrs.selectable = true;
    if (attrs.annotation_count == null) attrs.annotation_count = 0;
    Backbone.Model.call(this, attrs);
    var id = this.id;
    this.notes = new dc.model.NoteSet();
    this.notes.url = function() {
      return 'documents/' + id + '/annotations';
    };
    this.pageEntities = new dc.model.EntitySet();
  },

  // If this document does not belong to a collection, it still has a URL.
  url : function() {
    if (!this.collection) return '/documents/' + this.id;
    return Backbone.Model.prototype.url.call(this);
  },

  // Generate the canonical URL for opening this document, over SSL if we're
  // currently secured.
  viewerUrl : function() {
    var base = this.get('document_viewer_url').replace(/^http:/, '');
    return window.location.protocol + base;
  },

  // Generate the published URL for opening this document.
  publishedUrl : function() {
    return this.get('remote_url') || this.get('detected_remote_url');
  },

  // Generate the canonical id for this document.
  canonicalId : function() {
    return this.id + '-' + this.get('slug');
  },

  formatDay : DateUtils.create('%b %e, %Y'),

  formatTime : DateUtils.create('%l:%M %P'),

  // Generate the date object for this Document's `publish_at`.
  publishAtDate : function() {
    var date = this.get('publish_at');
    return date && DateUtils.parseRfc(date);
  },

  // Standard display of `publish_at`.
  formattedPublishAtDate : function() {
    var date = this.publishAtDate();
    return date && (this.formatDay(date) + ' at ' + this.formatTime(date));
  },

  openViewer : function() {
    if (this.checkBusy()) return;
    window.open(this.viewerUrl());
  },

  openPublishedViewer : function() {
    if (this.checkBusy()) return;
    if (!this.isPublished()) return dc.ui.Dialog.alert('"' + this.get('title') + '" is not published.');
    window.open(this.publishedUrl());
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
    var current = Accounts.current();
    return current && Accounts.current().checkAllowedToEdit(this);
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
    return _.uniq(this.pageEntities.map(function(m){ return m.get('value'); }));
  },

  isPending : function() {
    return this.get('access') == dc.access.PENDING;
  },

  isPublic : function() {
    return this.get('access') == dc.access.PUBLIC;
  },

  isPublished : function() {
    return this.isPublic() && this.publishedUrl();
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

dc.model.DocumentSet = Backbone.Collection.extend({

  model    : dc.model.Document,

  EMBED_FORBIDDEN : "At this stage in the beta, you may only embed documents you've uploaded yourself.",

  POLL_INTERVAL : 10000, // 10 seconds.

  url : '/documents',

  constructor : function(options) {
    Backbone.Collection.call(this, options);
    this._polling = false;
    _.bindAll(this, 'poll', 'downloadViewers', 'downloadSelectedPDF', 'downloadSelectedFullText', '_onModelChanged');
    this.bind('change', this._onModelChanged);
  },

  comparator : function(doc) {
    return doc.get('index');
  },

  pending : function() {
    return this.select(function(doc){ return doc.isPending(); });
  },

  subtitle : function(count) {
    return count > 1 ? count + ' Documents' : '';
  },

  // Given a list of documents and an attribute, return the value of the
  // attribute if identical, or null if divergent.
  sharedAttribute : function(docs, attr) {
    var attrs = _.uniq(_.map(docs, function(doc){ return doc.get(attr); }));
    return attrs.length > 1 ? false : attrs[0];
  },

  selectedPublicCount : function() {
    return _.reduce(this.selected(), function(memo, doc){
      return memo + doc.isPublic() ? 1 : 0;
    }, 0);
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
      var counter = docs.length;
      var progress = dc.ui.Dialog.progress('Deleting Documents&hellip;');
      _(docs).each(function(doc){ doc.destroy({success : function() {
        if (!--counter) progress.close();
      }}); });
      Projects.removeDocuments(docs);
      return true;
    }, this));
  },

  editAccess : function(docs) {
    var options = {information: this.subtitle(docs.length)};
    if (!this.allowedToEdit(docs)) return;
    var current = this.sharedAttribute(docs, 'access') || dc.access.PRIVATE;
    dc.ui.Dialog.choose('Access Level', [
      {text : 'Public Access',  description : 'Anyone on the internet can search for and view the document.', value : dc.access.PUBLIC, selected : current == dc.access.PUBLIC},
      {text : 'Private Access', description : 'Only people explicitly granted permission (via collaboration) may access.', value : dc.access.PRIVATE, selected : current == dc.access.PRIVATE},
      {text : 'Private to ' + dc.account.organization.name, description : 'Only the people in your organization may view the document.', value : dc.access.ORGANIZATION, selected : current == dc.access.ORGANIZATION}
    ], function(access) {
      _.each(docs, function(doc) { doc.save({access : parseInt(access, 10)}); });
      var notification = 'Access updated for ' + docs.length + ' ' + Inflector.pluralize('document', docs.length);
      dc.ui.notifier.show({mode : 'info', text : notification});
      return true;
    }, options);
  },

  // We override `add` to listen for uploading documents, and to start polling
  // for changes.
  add : function(model, options) {
    Backbone.Collection.prototype.add.call(this, model, options);
    this._checkForPending();
  },

  // We override `refresh` to cancel the polling action if the current set
  // has no pending documents.
  refresh : function(models, options) {
    this._resetSelection();
    if (!this.pending().length) this.stopPolling();
    Backbone.Collection.prototype.refresh.call(this, models, options);
  },

  // When one of our models has changed, if it has changed its access level
  // to pending, start polling.
  _onModelChanged : function(doc) {
    if (doc.hasChanged('access') && doc.isPending()) this._checkForPending();
  },

  _checkForPending : function() {
    if (this._polling) return false;
    if (!this.pending().length) return false;
    this.startPolling();
  }

});

_.extend(dc.model.DocumentSet.prototype, dc.model.Selectable);

// The main set of Documents.
window.Documents = new dc.model.DocumentSet();
