// A tile view for previewing a Document in a listing.
dc.ui.Note = dc.View.extend({

  className : 'note',

  callbacks : {
    '.note_title.click':  'viewNoteInDocument',
    '.page_number.click': 'viewNoteInDocument',
    '.edit_note.click':   'editNote',
    '.cancel_note.click': 'cancelNote',
    '.save_note.click':   'saveNote',
    '.delete_note.click': 'deleteNote'
  },

  constructor : function(options) {
    this.base(options);
    this.setMode(this.model.get('access'), 'access');
    _.bindAll(this, 'render');
    this.model.bind(dc.Model.CHANGED, this.render);
  },

  render : function() {
    var data = _.extend(this.model.attributes(), {src: this.model.imageUrl(), coords : this.model.coordinates()});
    $(this.el).html(JST.document_note(data));
    this.setMode('display', 'visible');
    this.setCallbacks();
    return this;
  },

  viewNoteInDocument : function() {
    var suffix = '#document/p' + this.model.get('page');
    window.open(this.model.document().get('document_viewer_url') + suffix);
  },

  editNote : function() {
    this.setMode('edit', 'visible');
  },

  cancelNote : function() {
    this.setMode('display', 'visible');
  },

  saveNote : function() {
    this.setMode('display', 'visible');
    this.set.update(this.model, {
      title   : $('.note_title_input', this.el).val(),
      content : $('.note_text_edit', this.el).val()
    });
  },

  deleteNote : function() {
    dc.ui.Dialog.confirm('Are you sure you want to delete this note?', _.bind(function() {
      $(this.el).remove();
      this.set.destroy(this.model);
      this.model.document().decrementNotes();
      return true;
    }, this));
  }

});