// A tile view for previewing a Document in a listing.
dc.ui.Document = dc.View.extend({

  // To display if the document failed to upload.
  ERROR_MESSAGE : "The document failed to import successfully. We've been notified of the problem, \
    and periodically review failed documents. You can try deleting this document, \
    re-saving the PDF with Acrobat or Preview, and reducing the file size before uploading again.\
    For direct help, email us at <span class=\"email\">support@documentcloud.org</span>",

  className : 'document',

  callbacks : {
    '.doc_title.mousedown'    : '_noSelect',
    '.doc_title.click'        : 'select',
    '.doc_title.dblclick'     : 'viewDocument',
    '.icon.doc.click'         : 'select',
    '.icon.doc.dblclick'      : 'viewDocument',
    '.show_notes.click'       : 'toggleNotes',
    '.title .edit_glyph.click': 'openDialog'
  },

  pageCallbacks : {
    '.page.click'         : '_openEntityOnPage',
    '.cancel_search.click': '_hidePages'
  },

  constructor : function(options) {
    this.base(options);
    this.el.id = 'document_' + this.model.id;
    this.setMode(this.model.get('annotation_count') ? 'owns' : 'no', 'notes');
    _.bindAll(this, '_onDocumentChange', '_onDrop', '_addNote', '_renderNotes', '_renderPages');
    this.model.bind(dc.Model.CHANGED, this._onDocumentChange);
    this.model.notes.bind(dc.Set.MODEL_ADDED, this._addNote);
    this.model.notes.bind(dc.Set.REFRESHED, this._renderNotes);
    this.model.pageEntities.bind(dc.Set.REFRESHED, this._renderPages);
  },

  render : function() {
    var me = this;
    var title = this.model.get('title');
    var data = _.clone(this.model.attributes());
    data = _.extend(data, {
      created_at    : data.created_at.replace(/\s/g, '&nbsp;'),
      editable      : this.model.allowedToEdit(),
      icon          : this._iconAttributes(),
      thumbnail_url : this._thumbnailURL(),
      description   : this._description()
    });
    $(this.el).html(JST['document/tile'](data));
    $('.doc.icon', this.el).draggable({ghost : true, onDrop : this._onDrop});
    this.notesEl = $('.notes', this.el);
    this.pagesEl = $('.pages', this.el);
    this.model.notes.each(function(note){ me._addNote(note); });
    if (!this.options.noCallbacks) this.setCallbacks();
    this.setMode(dc.access.NAMES[this.model.get('access')], 'access');
    this._setSelected();
    return this;
  },

  // Desktop-style selection.
  select : function(e) {
    e.preventDefault();
    if (!dc.app.accountId) return;
    if (!this.model.get('selectable')) return;
    var alreadySelected =  this.model.get('selected');
    var hk = dc.app.hotkeys;
    var anchor = Documents.firstSelection || Documents.selected()[0];
    if (hk.command || hk.control) {
      // Toggle.
      this.model.set({selected : !alreadySelected});
    } else if (hk.shift && anchor) {
      // Range.
      var docs = Documents.models();
      var idx = _.indexOf(docs, this.model), aidx = _.indexOf(docs, anchor);
      var start = Math.min(idx, aidx), end = Math.max(idx, aidx);
      _.each(docs, function(doc, index) {
        doc.set({selected : index >= start && index <= end});
      });
    } else {
      // Regular.
      Documents.deselectAll();
      this.model.set({selected : true});
    }
  },

  viewDocument : function(e) {
    e.preventDefault();
    this.model.openViewer();
    return false;
  },

  viewPDF : function() {
    this.model.openPDF();
  },

  viewFullText : function() {
    this.model.openText();
  },

  downloadViewer : function() {
    if (this.checkBusy()) return;
    this.model.downloadViewer();
  },

  // Open an edit dialog for the currently selected documents, if this
  // document is among them. Otherwise, open the dialog just for this document.
  openDialog : function() {
    dc.ui.DocumentDialog.open(this.model);
  },

  toggleNotes : function(e) {
    e.stopPropagation();
    var next = _.bind(function() {
      var model = Documents.get(this.model.id);
      if (this.modes.notes == 'has') return this.setMode('owns', 'notes');
      if (model.notes.populated) return this.setMode('has', 'notes');
      dc.ui.spinner.show('loading notes');
      window.scroll(0, $('#document_' + model.id).offset().top - 10);
      model.notes.populate({success: dc.ui.spinner.hide });
    }, this);
    dc.app.paginator.mini ? dc.app.paginator.toggleSize(next, this.model) : next();
  },

  deleteDocument : function(e) {
    e.preventDefault();
    var destructor = _.bind(Documents.destroy, Documents, this.model);
    dc.ui.Dialog.confirm('Really delete "' + this.model.get('title') + '" ?', destructor);
  },

  _iconAttributes : function() {
    var access = this.model.get('access');
    switch (access) {
      case dc.access.PUBLIC:       return null;
      case dc.access.PENDING:      return {className : 'spinner',    title : 'Uploading...'};
      case dc.access.ERROR:        return {className : 'alert_gray', title : 'Broken document'};
      case dc.access.ORGANIZATION: return {className : 'lock',       title : 'Private to ' + dc.app.organization.name};
      case dc.access.PRIVATE:      return {className : 'lock',       title : 'Private'};
    }
  },

  _thumbnailURL : function() {
    var access = this.model.get('access');
    switch (access) {
      case dc.access.PENDING: return '/images/embed/documents/processing.png';
      case dc.access.ERROR:   return '/images/embed/documents/failed.png';
      default:                return this.model.get('thumbnail_url');
    }
  },

  _description : function() {
    if (this.model.get('access') == dc.access.ERROR) return this.ERROR_MESSAGE;
    return this.model.displayDescription();
  },

  _setSelected : function() {
    var sel = this.model.get('selected');
    this.setMode(sel ? 'is' : 'not', 'selected');
  },

  _onDocumentChange : function() {
    if (this.model.hasChanged('selected')) return this._setSelected();
    if (this.model.hasChanged('annotation_count')) return $('span.note_count', this.el).text(this.model.get('annotation_count'));
    this.render();
  },

  _addNote : function(note) {
    this.notesEl.append((new dc.ui.Note({model : note, set : this.model.notes})).render().el);
  },

  _renderNotes : function() {
    _.each(this.model.notes.models(), this._addNote);
    this.setMode('has', 'notes');
  },

  _renderPages : function() {
    this.pagesEl.html(JST['document/pages']({doc : this.model}));
    this.setCallbacks(this.pageCallbacks);
  },

  _hidePages : function() {
    this.pagesEl.html('');
  },

  _openEntityOnPage : function(e) {
    var el    = $(e.target).closest('.page');
    var id    = el.attr('data-id');
    var page  = el.attr('data-page');
    window.open(this.model.url() + "?entity=" + id + '&page=' + page);
  },

  // When the document is dropped onto a project, add it to the project.
  _onDrop : function(e) {
    var docs = [this.model];
    var selected = Documents.selected();
    if (selected.length && _.include(selected, this.model)) docs = selected;
    var x = e.pageX, y = e.pageY;
    $('#organizer .project').each(function() {
      var top = $(this).offset().top, left = $(this).offset().left;
      var right = left + $(this).outerWidth(), bottom = top + $(this).outerHeight();
      if (left < x && right > x && top < y && bottom > y) {
        var project = Projects.getByCid($(this).attr('data-project-cid'));
        if (project) project.addDocuments(docs);
        return false;
      }
    });
  },

  _noSelect : function(e) {
    e.preventDefault();
  }

});