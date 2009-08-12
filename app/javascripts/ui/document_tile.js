dc.ui.DocumentTile = dc.ui.View.extend({
  
  className : 'document_tile',
  
  constructor : function(data) {
    this.base(data);
    this.options.full_text_url = '/documents/full_text/' + this.options.id;
    this.el.id = 'document_tile_' + this.options.id;
  },
  
  render : function() {
    $(this.el).html(dc.templates.DOCUMENT_TILE(this.options));
    return this;
  }
  
});