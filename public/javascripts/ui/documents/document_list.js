// Responsible for rendering a list of Documents. The tiles can be displayed
// in a number of different sizes.
dc.ui.DocumentList = Backbone.View.extend({

  SLOP      : 3,

  id        : 'document_list',

  events : {
    'mousedown': '_startDeselect',
    'click':     '_endDeselect'
  },

  constructor : function(options) {
    Backbone.View.call(this, options);
    _.bindAll(this, 'refresh', '_removeDocument', '_addDocument', '_onSelect');
    Documents.bind('refresh', this.refresh);
    Documents.bind('remove',   this._removeDocument);
    Documents.bind('add',     this._addDocument);
  },

  render : function() {
    $('.search_tab_content').selectable({ignore : '.noselect, .minibutton', select : '.icon.doc', onSelect : this._onSelect});
    return this;
  },

  refresh : function() {
    $(this.el).html('');
    var views = Documents.map(function(m){
      return (new dc.ui.Document({model : m})).render().el;
    });
    $(this.el).append(views.concat(this.make('div', {'class' : 'clear'})));
  },

  _onSelect : function(els) {
    var active = {};
    _.each(els, function(icon) {
      var id = $(icon).attr('data-id');
      active[id] = true;
      Documents.get(id).set({selected : true});
    });
    if (!dc.app.hotkeys.shift && !dc.app.hotkeys.command) {
      _.each(Documents.selected(), function(doc) {
        if (!active[doc.id]) doc.set({selected : false});
      });
    }
  },

  _startDeselect : function(e) {
    this._pageX = e.pageX;
    this._pageY = e.pageY;
  },

  _endDeselect : function(e) {
    if (dc.app.hotkeys.shift || dc.app.hotkeys.command || dc.app.hotkeys.control) return;
    if ($(e.target).hasClass('doc_title') || $(e.target).hasClass('doc') || $(e.target).hasClass('edit_glyph')) return;
    if ((Math.abs(e.pageX - this._pageX) > this.SLOP) ||
        (Math.abs(e.pageY - this._pageY) > this.SLOP)) return;
    Documents.deselectAll();
  },

  _addDocument : function(doc) {
    var view = new dc.ui.Document({model : doc});
    $(this.el).prepend(view.render().el);
  },

  _removeDocument : function(doc) {
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