dc.ui.DocumentList = dc.ui.View.extend({
  
  className : 'document_list',
  
  callbacks : [
    ['.view_small',   'click',    'viewSmall'],
    ['.view_medium',  'click',    'viewMedium'],
    ['.view_large',   'click',    'viewLarge']
  ],
  
  render : function() {
    $(this.el).html(dc.templates.DOCUMENT_LIST({}));
    return this;
  },
  
  viewSmall : function() {
    alert('small!');
  },
  
  viewMedium : function() {
    alert('medium!');
  },
  
  viewLarge : function() {
    alert('large!');
  }
  
});