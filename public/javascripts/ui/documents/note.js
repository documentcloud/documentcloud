// A tile view for previewing a Document in a listing.
dc.ui.Note = dc.View.extend({

  className : 'note',

  callbacks : {
    '.note_title.click':  'viewNoteInDocument',
    '.page_number.click': 'viewNoteInDocument'
  },

  constructor : function(options) {
    this.base(options);
    this.setMode(this.model.get('access'), 'access');
  },

  render : function() {
    var data = _.extend(this.model.attributes(), {src: this.model.imageUrl(), coords : this.model.coordinates()});
    $(this.el).html(JST.document_note(data));
    this.setCallbacks();
    return this;
  },

  viewNoteInDocument : function() {
    var suffix = '#document/p' + this.model.get('page');
    window.open(this.model.document().get('document_viewer_url') + suffix);
  }

});