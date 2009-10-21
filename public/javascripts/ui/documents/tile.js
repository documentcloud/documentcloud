// A tile view for previewing a Document in a listing.
dc.ui.DocumentTile = dc.View.extend({
  
  className : 'document_tile',
  
  callbacks : [
    ['.view_document',    'click',  'viewPDF'],
    ['.view_pdf',         'click',  'viewPDF'],
    ['.view_text',        'click',  'viewFullText'],
    ['.delete_document',  'click',  'deleteDocument'],
    ['.icon',             'click',  'select']
  ],
  
  constructor : function(doc) {
    this.base();
    this.model = doc;
    this.el.id = 'document_tile_' + this.model.id;
  },
  
  render : function() {
    $(this.el).html(dc.templates.DOCUMENT_TILE({'document' : this.model}));
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
  
  viewPDF : function() {
    window.open(this.model.pdfURL());
  },
  
  viewFullText : function() {
    window.open(this.model.textURL());
  },
  
  deleteDocument : function(e) {
    e.preventDefault();
    if (!confirm('Really delete "' + this.model.get('title') + '" ?')) return;
    Documents.destroy(this.model);
  }
  
});