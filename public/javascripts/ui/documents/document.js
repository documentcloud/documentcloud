// A tile view for previewing a Document in a listing.
dc.ui.Document = dc.View.extend({

  className : 'document',

  callbacks : {
    '.view_document.click':  'viewDocument',
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
    var title = this.model.get('title');
    var data = _.clone(this.model.attributes());
    data = _.extend(data, {
      thumbnail_url : this.model.thumbnailURL(),
      description   : this.model.displayDescription()
    });
    $(this.el).html(JST.document_tile(data));
    $('.doc.icon', this.el).draggable({ghost : true, onDrop : this._onDrop});
    this.notesEl = $('.notes', this.el);
    if (!this.options.noCallbacks) this.setCallbacks();
    this.setMode('access', this.model.get('access'));
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

  toggleNotes : function() {
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