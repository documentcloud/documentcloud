// Responsible for rendering a list of Documents. The tiles can be displayed
// in a number of different sizes.
dc.ui.DocumentList = dc.View.extend({

  id        : 'document_list',
  className : 'panel',

  callbacks : {
    'el.click': '_deselect'
  },

  constructor : function(options) {
    this.base(options);
    _.bindAll(this, 'refresh', '_removeDocument', '_addDocument');
    Documents.bind(dc.Set.REFRESHED,     this.refresh);
    Documents.bind(dc.Set.MODEL_REMOVED, this._removeDocument);
    Documents.bind(dc.Set.MODEL_ADDED,   this._addDocument);
  },

  render : function() {
    $(this.el).append([dc.app.visualizer.el, dc.app.entities.el]);
    this.setCallbacks();
    return this;
  },

  refresh : function() {
    $('.document', this.el).remove();
    var views = _.map(Documents.models(), function(m){
      return (new dc.ui.Document({model : m})).render().el;
    });
    $(this.el).append(views);
  },

  _deselect : function(e) {
    var tile = $(e.target).closest('.is_selected');
    if (tile.length) return;
    Documents.deselectAll();
  },

  _addDocument : function(e, doc) {
    var view = new dc.ui.Document({model : doc});
    $(this.el).prepend(view.render().el);
  },

  _removeDocument : function(e, doc) {
    $('#document_' + doc.id).remove();
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