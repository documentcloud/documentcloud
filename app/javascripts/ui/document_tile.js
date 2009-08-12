dc.ui.DocumentTile = Base.extend({
  
  constructor : function(data) {
    this.data = data;
    this.data.full_text_url = '/documents/full_text/' + this.data.id;
  },
  
  render : function() {
    return dc.templates.WORKSPACE_DOCUMENT_TILE(this.data);
  }
  
});