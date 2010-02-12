// A tile view for previewing a Document in a listing.
dc.ui.Document = dc.View.extend({

  className : 'document',

  callbacks : {
    '.view_document.click': 'viewDocument',
    '.icon.click'         :  'select',
    '.show_notes.click'   :  'toggleNotes'
  },

  constructor : function(doc, mode) {
    this.mode = mode;
    if (mode) this.className += ' ' + mode;
    this.base({model : doc});
    this.el.id = 'document_' + this.model.id;
    this.setMode('no', 'notes');
    _.bindAll(this, '_onDocumentChange', '_onDrop', '_addNote', '_onNotesLoaded');
    this.model.bind(dc.Model.CHANGED, this._onDocumentChange);
    this.model.notes.bind(dc.Set.MODEL_ADDED, this._addNote);
  },

  render : function() {
    var title = this.model.get('title');
    $(this.el).html(JST.document_tile({
      thumbnail   : this.model.get('thumbnail_url'),
      title       : this.mode == 'viz' ? Inflector.truncate(title, 55) : title,
      source      : this.model.get('source'),
      description : this.model.displayDescription(),
      pub         : this.model.get('access') == dc.access.PUBLIC,
      page_count  : this.model.get('page_count'),
      note_count  : this.model.get('annotation_count')
    }));
    $('.doc.icon', this.el).draggable({ghost : true, onDrop : this._onDrop});
    this.notesEl = $('.notes', this.el);
    this.setCallbacks();
    this._setSelected();
    return this;
  },

  select : function() {
    if (!dc.app.accountId) return;
    var selected = !this.model.get('selected');
    if (dc.app.hotkeys.shift) {
      return selected ? Documents.selectAll() : Documents.deselectAll();
    }
    this.model.set({selected : selected});
  },

  viewDocument : function() {
    window.open(this.model.get('document_viewer_url'));
  },

  viewPDF : function() {
    window.open(this.model.get('pdf_url'));
  },

  viewFullText : function() {
    window.open(this.model.get('full_text_url'));
  },

  downloadViewer : function() {
    this.model.downloadViewer();
  },

  toggleNotes : function() {
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

  _setSelected : function() {
    var sel = this.model.get('selected');
    this.setMode(sel ? 'is' : 'not', 'selected');
    $(this.el).toggleClass('gradient_selected', !!sel);
  },

  _onDocumentChange : function() {
    var changed = this.model.hasChanged('access');
    changed ? this.render() : this._setSelected();
  },

  _onNotesLoaded : function() {
    dc.ui.spinner.hide();
    this.setMode('has', 'notes');
  },

  _addNote : function(e, note) {
    this.notesEl.append((new dc.ui.Note({model : note})).render().el);
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
        project.addDocuments(docs);
        return false;
      }
    });
  }

});