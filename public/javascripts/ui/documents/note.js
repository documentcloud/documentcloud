// A tile view for previewing a Document in a listing.
dc.ui.Note = Backbone.View.extend({

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
    Backbone.View.call(this, options);
    this.setMode(this.model.get('access'), 'access');
    _.bindAll(this, 'render');
    this.model.bind('change', this.render);
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
    this.$('.note_title_input').val(this.model.get('title'));
    this.$('.note_text_edit').val(this.model.get('content'));
    this.setMode('edit', 'visible');
  },

  cancelNote : function() {
    this.setMode('display', 'visible');
  },

  saveNote : function() {
    this.setMode('display', 'visible');
    this.model.save({
      title   : this.$('.note_title_input').val(),
      content : this.$('.note_text_edit').val()
    });
  },

  deleteNote : function() {
    dc.ui.Dialog.confirm('Are you sure you want to delete this note?', _.bind(function() {
      this.collection.destroy(this.model, {success : _.bind(function() {
        $(this.el).remove();
        this.model.document().decrementNotes();
      }, this)});
      return true;
    }, this));
  }

});