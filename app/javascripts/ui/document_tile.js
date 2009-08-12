dc.ui.DocumentTile = dc.ui.View.extend({
  
  constructor : function(data) {
    this.base(data);
    this.options.full_text_url = '/documents/full_text/' + this.options.id;
  },
  
  render : function() {
    return dc.templates.DOCUMENT_TILE(this.options);
  }
  
});