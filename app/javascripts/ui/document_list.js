// Responsible for rendering a list of DocumentTiles. The tiles can be displayed
// in a number of different sizes.
dc.ui.DocumentList = dc.View.extend({
  
  className : 'document_list',
  
  callbacks : [
    ['.view_small',   'click',    'viewSmall'],
    ['.view_medium',  'click',    'viewMedium'],
    ['.view_large',   'click',    'viewLarge']
  ],
  
  constructor : function(options) {
    this.base(options);
    $(this.el).addClass('large_size');
  },
  
  render : function() {
    $(this.el).html(dc.templates.DOCUMENT_LIST({}));
    return this;
  },
  
  viewSmall : function() {
    this.setMode('small', 'size');
  },
  
  viewMedium : function() {
    this.setMode('medium', 'size');
  },
  
  viewLarge : function() {
    this.setMode('large', 'size');
  }
  
});