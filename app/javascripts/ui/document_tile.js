dc.ui.DocumentTile = function(data) {
  this.data = data;
};

dc.ui.DocumentTile.prototype = {
  
  render : function() {
    return dc.templates.WORKSPACE_DOCUMENT_TILE(this.data);
  }
  
};