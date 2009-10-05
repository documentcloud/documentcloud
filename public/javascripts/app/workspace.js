// Main controller for the workspace. Orchestrates subviews. Handles searching
// (for now). Still needs to be cleaned up. Search should be pulled out.
dc.app.workspace = new dc.View();
_.extend(dc.app.workspace, {
  
  callbacks : [
    ['#wordmark',               'click',      'goHome'],
    ['#upload_document_button', 'click',      'showUploadForm']
  ],
  
  // Initializes the workspace, binding it to <body>.
  initialize : function() {
    this.el = $('body').get();
    
    this.sidebar = new dc.ui.Sidebar();
    $('#content').append(this.sidebar.render().el);
    
    this.panel = new dc.ui.Panel();
    $('#content').append(this.panel.render().el);
                
    dc.app.searchBox = new dc.ui.SearchBox();
    
    this.setCallbacks();
    dc.history.loadURL();
  },
  
  // Return to the DocumentCloud homepage.
  goHome : function() {
    window.location = '/';
  },
  
  // Show the document upload form.
  showUploadForm : function() {
    var docUpload = new dc.ui.DocumentUpload();
    this.sidebar.show(docUpload.helpContent());
    this.panel.show(docUpload.render().el);
  }
  
});