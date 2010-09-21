// A tile view for previewing a Document in a listing.
dc.ui.Note = dc.Controller.extend({

  className : 'note noselect',

  callbacks : {
    '.title_link.click':  'viewNoteInDocument',
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
    this.model.bind('model:changed', this.render);
  },

  render : function() {
    var data = _.extend(this.model.attributes(), {note : this.model});
    $(this.el).html(JST['document/note'](data));
    this.setMode('display', 'visible');
    this.setCallbacks();
    return this;
  },

  viewNoteInDocument : function() {
    var suffix = '#document/p' + this.model.get('page');
    window.open(this.model.document().url() + suffix);
  },

  editNote : function() {
    if (!this.model.checkAllowedToEdit()) return dc.ui.Dialog.alert("You don't have permission to edit this note.");
    $('.note_title_input', this.el).val(this.model.get('title'));
    $('.note_text_edit', this.el).val(this.model.get('content'));
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
      this.set.destroy(this.model, {success : _.bind(function() {
        $(this.el).remove();
        this.model.document().decrementNotes();
      }, this)});
      return true;
    }, this));
  }

});