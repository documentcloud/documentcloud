// Responsible for rendering a list of DocumentTiles. The tiles can be displayed
// in a number of different sizes.
dc.ui.DocumentList = dc.View.extend({

  className : 'document_list',

  callbacks : {
    '.view_small.click':  'viewSmall',
    '.view_medium.click': 'viewMedium',
    '.view_large.click':  'viewLarge'
  },

  constructor : function(options) {
    this.base(options);
    $(this.el).addClass('large_size');
    this.set.bind(dc.Set.MODEL_REMOVED, this.removeDocument);
  },

  render : function() {
    $(this.el).html(JST.document_list({}));
    this.setCallbacks();
    return this;
  },

  removeDocument : function(e, model) {
    $('#document_tile_' + model.id).remove();
  },

  viewSmall : function() {
    this.setMode('small', 'size');
  },

  viewMedium : function() {
    this.setMode('medium', 'size');
  },

  viewLarge : function() {
    this.setMode('large', 'size');
  }

});