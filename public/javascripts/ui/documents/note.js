// A tile view for previewing a Document in a listing.
dc.ui.Note = dc.View.extend({

  className : 'note',

  callbacks : {},

  constructor : function(options) {
    this.base(options);
    this.setMode(this.model.get('access'), 'access');
  },

  render : function() {
    var data = _.extend(this.model.attributes(), {src: this.model.imageUrl(), coords : this.model.coordinates()});
    $(this.el).html(JST.document_note(data));
    this.setCallbacks();
    return this;
  }

});