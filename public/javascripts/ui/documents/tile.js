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
    this.base();
    this.document = doc;
    this.el.id = 'document_tile_' + this.document.id;
  },
  
  render : function() {
    $(this.el).html(dc.templates.DOCUMENT_TILE({'document' : this.document}));
    this.setCallbacks();
    return this;
  },
  
  viewPDF : function() {
    window.open(this.document.pdfURL());
  },
  
  viewFullText : function() {
    window.open(this.document.textURL());
  },
  
  deleteDocument : function(e) {
    e.preventDefault();
    if (!confirm('Really delete "' + this.document.get('title') + '" ?')) return;
    Documents.destroy(this.document);
  }
  
});