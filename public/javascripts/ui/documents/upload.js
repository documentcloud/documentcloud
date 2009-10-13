// The Sidebar. Switches contexts between different subviews.
dc.ui.DocumentUpload = dc.View.extend({
  
  className : 'document_upload panel',
  
  render : function() {
    var params = {organization : currentAccount.get('organization_name')};
    $(this.el).html(dc.templates.DOCUMENT_UPLOAD_FORM(params));
    $('#document_upload_container').html(this.el);
    $('#upload_help_container').html(this.helpContent());
    return this;
  },
  
  helpContent : function() {
    return dc.templates.DOCUMENT_UPLOAD_HELP({});
  }
  
});