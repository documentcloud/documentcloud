// A tile view for previewing a Document in a listing.
dc.ui.DocumentTile = dc.View.extend({
  
  className : 'document_tile',
  
  callbacks : [
    ['.delete_document',  'click',  'deleteDocument']
  ],
  
  constructor : function(doc) {
    this.base(doc.getAttributes());
    this.options.display_url = '/documents/display/' + this.options.id;
    this.el.id = 'document_tile_' + this.options.id;
  },
  
  render : function() {
    $(this.el).html(dc.templates.DOCUMENT_TILE(this.options));
    this.setCallbacks();
    return this;
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