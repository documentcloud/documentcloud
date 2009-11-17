// A tile view for previewing a Document in a listing.
dc.ui.DocumentTile = dc.View.extend({

  className : 'document_tile',

  callbacks : [
    ['.view_document',    'click',  'viewDocument'],
    ['.view_pdf',         'click',  'viewPDF'],
    ['.view_text',        'click',  'viewFullText'],
    ['.download_viewer',  'click',  'downloadViewer'],
    ['.delete_document',  'click',  'deleteDocument'],
    ['.icon',             'click',  'select']
  ],

  constructor : function(doc, mode) {
    this.mode = mode;
    if (mode) this.className += ' ' + mode;
    this.base();
    this.model = doc;
    this.el.id = 'document_' + (mode || 'tile') + '_' + this.model.id;
  },

  render : function() {
    var title = this.model.get('title');
    $(this.el).html(JST.document_tile({
      'thumbnail' : this.model.get('thumbnail_url'),
      'title'     : this.mode == 'viz' ? Inflector.truncate(title, 55) : title,
      'source'    : this.model.get('source'),
      'summary'   : this.model.get('summary')
    }));
    this.setCallbacks();
    this.setMode('not', 'selected');
    return this;
  },

  select : function() {
    if (!dc.app.accountId) return;
    this.model.selected = !this.model.selected;
    this.setMode(this.model.selected ? 'is' : 'not', 'selected');
    dc.app.toolbar.display();
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
    $('#hidden_iframe').attr({src : this.model.get('download_viewer_url')});
  },

  deleteDocument : function(e) {
    e.preventDefault();
    if (!confirm('Really delete "' + this.model.get('title') + '" ?')) return;
    Documents.destroy(this.model);
  }

});