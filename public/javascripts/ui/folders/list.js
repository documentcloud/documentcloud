dc.ui.FolderList = dc.View.extend({
  
  id : 'folder_list',
  
  callbacks : [],
  
  render : function() {
    $(this.el).html(dc.templates.FOLDER_LIST({}));
    return this;
  }
  
});