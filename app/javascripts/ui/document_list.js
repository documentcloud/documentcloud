dc.ui.DocumentList = dc.ui.View.extend({
  
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