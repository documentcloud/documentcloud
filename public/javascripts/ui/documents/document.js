// A tile view for previewing a Document in a listing.
dc.ui.Document = dc.View.extend({

  // To display if the document failed to upload.
  ERROR_MESSAGE : "The document failed to import successfully. We've been notified of the problem.\
    You can try deleting this document, re-saving the PDF with Acrobat or Preview, and reducing the file size before uploading again.",

  className : 'document',

  callbacks : {
    '.view_document.click':  'viewDocument',
    '.icon.dblclick'      :  'viewDocument',
    '.icon.click'         :  'select',
    '.show_notes.click'   :  'toggleNotes'
  },

  constructor : function(options) {
    this.base(options);
    this.el.id = 'document_' + this.model.id;
    this.setMode('no', 'notes');
    _.bindAll(this, '_onDocumentChange', '_onDrop', '_addNote', '_onNotesLoaded');
    this.model.bind(dc.Model.CHANGED, this._onDocumentChange);
    this.model.notes.bind(dc.Set.MODEL_ADDED, this._addNote);
  },

  render : function() {
    var me = this;
    var title = this.model.get('title');
    var data = _.clone(this.model.attributes());
    data = _.extend(data, {
      icon          : this._iconName(),
      thumbnail_url : this._thumbnailURL(),
      description   : this._description()
    });
    $(this.el).html(JST.document_tile(data));
    $('.doc.icon', this.el).draggable({ghost : true, onDrop : this._onDrop});
    this.notesEl = $('.notes', this.el);
    this.model.notes.each(function(note){ me._addNote(null, note); });
    if (!this.options.noCallbacks) this.setCallbacks();
    this.setMode(dc.access.NAMES[this.model.get('access')], 'access');
    this._setSelected();
    return this;
  },

  // Desktop-style selection.
  select : function(e) {
    e.stopPropagation();
    if (!dc.app.accountId) return;
    var alreadySelected =  this.model.get('selected');
    var cmd = dc.app.hotkeys.command;
    if (cmd) {
      this.model.set({selected : !alreadySelected});
    } else {
      if (alreadySelected) return;
      Documents.deselectAll();
      this.model.set({selected : true});
    }
  },

  viewDocument : function(e) {
    e.stopPropagation();
    this.model.openViewer();
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

  toggleNotes : function(e) {
    e.stopPropagation();
    if (dc.app.visualizer.isOpen() || dc.app.entities.isOpen()) return;
    if (this.modes.notes == 'has') return this.setMode('no', 'notes');
    if (this.model.notes.populated) return this.setMode('has', 'notes');
    dc.ui.spinner.show('loading notes');
    if (!this.model.notes.populated) return this.model.notes.populate({success: this._onNotesLoaded});
  },

  deleteDocument : function(e) {
    e.preventDefault();
    var destructor = _.bind(Documents.destroy, Documents, this.model);
    dc.ui.Dialog.confirm('Really delete "' + this.model.get('title') + '" ?', destructor);
  },

  _iconName : function() {
    var access = this.model.get('access');
    switch (access) {
      case dc.access.PUBLIC:  return null;
      case dc.access.PENDING: return 'spinner';
      case dc.access.ERROR:   return 'warning_16';
      default:                return 'lock';
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
    $(this.el).toggleClass('gradient_selected', !!sel);
  },

  _onDocumentChange : function() {
    if (this.model.hasChanged('selected')) return this._setSelected();
    if (this.model.hasChanged('annotation_count')) return $('span.count', this.el).text(this.model.get('annotation_count'));
    this.render();
  },

  _onNotesLoaded : function() {
    dc.ui.spinner.hide();
    this.setMode('has', 'notes');
  },

  _addNote : function(e, note) {
    this.notesEl.append((new dc.ui.Note({model : note, set : this.model.notes})).render().el);
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
  }

});