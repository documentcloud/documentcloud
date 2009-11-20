// A tile view for previewing a Document in a listing.
dc.ui.DocumentTile = dc.View.extend({

  className : 'document_tile',

  callbacks : [
    ['.view_document',    'click',  'viewDocument'],
    // ['.view_pdf',         'click',  'viewPDF'],
    // ['.view_text',        'click',  'viewFullText'],
    // ['.download_viewer',  'click',  'downloadViewer'],
    // ['.delete_document',  'click',  'deleteDocument'],
    ['.icon',             'click',  'select']
  ],

  constructor : function(doc, mode) {
    this.mode = mode;
    if (mode) this.className += ' ' + mode;
    this.base({model : doc});
    this.el.id = 'document_' + (mode || 'tile') + '_' + this.model.id;
    this.model.bind(dc.Model.CHANGED, _.bind(this._setSelected, this));
  },

  render : function() {
    var title = this.model.get('title');
    $(this.el).html(JST.document_tile({
      'thumbnail' : this.model.get('thumbnail_url'),
      'title'     : this.mode == 'viz' ? Inflector.truncate(title, 55) : title,
      'source'    : this.model.get('source'),
      'summary'   : this.model.inlineSummary()
    }));
    this.setCallbacks();
    this._setSelected();
    return this;
  },

  select : function() {
    if (!dc.app.accountId) return;
    var selected = !this.model.get('selected');
    this.model.set({selected : selected});
    dc.app.toolbar.display();
    dc.app.metaList.render();
    var count = Documents.countSelected();
    count > 0 ? dc.ui.query.renderSelected(count) : dc.ui.query.render();
  },

  viewDocument : function() {
    window.open(this.model.get('document_viewer_url'));
  },

  viewPDF : function() {
    window.open(this.model.get('pdf_url'));
  },

  viewFullText : function() {
    window.open(this.model.get('full_text_url'));
  },

  downloadViewer : function() {
    this.model.downloadViewer();
  },

  deleteDocument : function(e) {
    e.preventDefault();
    if (!confirm('Really delete "' + this.model.get('title') + '" ?')) return;
    Documents.destroy(this.model);
  },

  _setSelected : function() {
    this.setMode(this.model.get('selected') ? 'is' : 'not', 'selected');
  }

});