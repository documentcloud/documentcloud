// Responsible for rendering a list of Documents. The tiles can be displayed
// in a number of different sizes.
dc.ui.DocumentList = Backbone.View.extend({

  // Threshold for dragging empty space in the document list. When below
  // this threshold, do not deselect documents.
  SLOP      : 3,

  id        : 'document_list',

  events : {
    'mousedown': '_startDeselect',
    'click':     '_endDeselect'
  },

  // Listen for new documents on the `Documents` Collection, which is populated
  // at load time and when searching.
  constructor : function(options) {
    Backbone.View.call(this, options);
    _.bindAll(this, 'refresh', '_removeDocument', '_addDocument', '_onSelect',
              '_maybeSelect');
    $(document).bind('keydown', this._maybeSelect);
    Documents.bind('refresh', this.refresh);
    Documents.bind('remove',  this._removeDocument);
    Documents.bind('add',     this._addDocument);
  },

  // Simply renders the list container, still waiting for documents.
  render : function() {
    this.setCallbacks();
    $('.search_tab_content').selectable({
      ignore : '.noselect, .minibutton',
      select : '.icon.doc',
      onSelect : this._onSelect
    });
    return this;
  },

  // Once there are Documents being populated, this view listens for a `Collection#refresh`,
  // which redraws all the Document tile views in this list view.
  refresh : function() {
    $(this.el).html('');
    var views = Documents.map(function(m){
      return (new dc.ui.Document({model : m})).render().el;
    });
    $(this.el).append(views.concat(this.make('div', {'class' : 'clear'})));
  },

  // When document tiles are lassoed by `.selection` in `render`, set their
  // `selected` attribute. Allows multiple document selection.
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

  // Handle cmd-a for select all.
  _maybeSelect : function(e) {
    var cmdA = dc.app.hotkeys.command && (e.which == 97 || e.which == 65);
    if (cmdA && !$(e.target).closest('input, textarea').length) {
      Documents.selectAll();
      return false;
    }
  },

  // Called when clicking on the document list but not on a document tile.
  // Used to check if the user is dragging a lasso around documents.
  _startDeselect : function(e) {
    this._pageX = e.pageX;
    this._pageY = e.pageY;
  },

  // On mouseup, check if the user is dragging a selection lasso. Has a grace
  // (`this.SLOP`) of a few pixels where a drag can still be considered a
  // deselect.
  _endDeselect : function(e) {
    if (dc.app.hotkeys.shift ||
        dc.app.hotkeys.command ||
        dc.app.hotkeys.control) return;
    if ($(e.target).hasClass('doc_title') ||
        $(e.target).hasClass('doc') ||
        $(e.target).hasClass('edit_glyph')) return;
    if ((Math.abs(e.pageX - this._pageX) > this.SLOP) ||
        (Math.abs(e.pageY - this._pageY) > this.SLOP)) return;

    Documents.deselectAll();
  },

  // Called when document models added to `Documents` collection.
  _addDocument : function(doc) {
    var view = new dc.ui.Document({model : doc});
    $(this.el).prepend(view.render().el);
  },

  // Called when document models deleted (and subsequently removed from `Documents`
  // collection).
  _removeDocument : function(doc) {
    $('#document_' + doc.id).remove();
  }

});