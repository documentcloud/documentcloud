// The Sidebar. Switches contexts between different subviews.
dc.ui.DocumentUpload = dc.View.extend({
  
  className : 'document_upload',
  
  render : function() {
    $(this.el).html(dc.templates.DOCUMENT_UPLOAD_FORM({}));
    return this;
  },
  
  helpContent : function() {
    return dc.templates.DOCUMENT_UPLOAD_HELP({});
  }
  
});