dc.ui.DocumentTile = function(data) {
  this.data = data;
  this.data.full_text_url = '/documents/full_text/' + this.data.id;
};

dc.ui.DocumentTile.prototype = {
  
  render : function() {
    return dc.templates.WORKSPACE_DOCUMENT_TILE(this.data);
  }
  
};