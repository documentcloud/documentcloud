// A tile view for previewing a Document in a listing.
dc.ui.DocumentTile = dc.View.extend({
  
  className : 'document_tile',
  
  callbacks : [
    ['.view_document',    'click',  'viewPDF'],
    ['.view_pdf',         'click',  'viewPDF'],
    ['.view_text',        'click',  'viewFullText'],
    ['.delete_document',  'click',  'deleteDocument']
  ],
  
  constructor : function(doc) {
    this.base(doc.attributes());
    this.el.id = 'document_tile_' + this.options.id;
  },
  
  render : function() {
    $(this.el).html(dc.templates.DOCUMENT_TILE(this.options));
    this.setCallbacks();
    return this;
  },
  
  viewPDF : function() {
    window.open(this.getDocument().pdfURL());
  },
  
  viewFullText : function() {
    window.open(this.getDocument().textURL());
  },
  
  getDocument : function() {
    return Documents.get(this.options.id);
  },
  
  deleteDocument : function(e) {
    e.preventDefault();
    if (!confirm('Really delete "' + this.options.title + '" ?')) return;
    Documents.destroy(Documents.get(this.options.id));
  }
  
});