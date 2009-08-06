dc.ui.DocumentTile = function(data) {
  this.data = data;
};

dc.ui.DocumentTile.prototype = {
  
  render : function() {
    return $(document.createElement('div'))
            .addClass('document_tile')
            .append(this.data.title);
  }
  
};