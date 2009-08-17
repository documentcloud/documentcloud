// A tile view for previewing a Document in a listing.
dc.ui.DocumentTile = dc.View.extend({
  
  className : 'document_tile',
  
  constructor : function(doc) {
    this.base(doc.getAttributes());
    this.options.display_url = '/documents/display/' + this.options.id;
    this.el.id = 'document_tile_' + this.options.id;
  },
  
  render : function() {
    $(this.el).html(dc.templates.DOCUMENT_TILE(this.options));
    return this;
  }
  
});