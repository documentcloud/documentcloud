// Main controller for the workspace. Orchestrates subviews. Handles searching
// (for now). Still needs to be cleaned up. Search should be pulled out.
dc.app.workspace = new dc.View();
_.extend(dc.app.workspace, {
  
  callbacks : [
    ['#documents_nav',    'click',    'showDocuments'],
    ['#upload_nav',       'click',    'showUploadForm']
  ],
  
  // Initializes the workspace, binding it to <body>.
  initialize : function() {
    this.el = $('body')[0];
    var content = $('#content');
    
    this.sidebar = new dc.ui.Sidebar();
    content.append(this.sidebar.render().el);
    
    this.panel = new dc.ui.Panel();
    content.append(this.panel.render().el);
                
    dc.app.searchBox = new dc.ui.SearchBox();
    
    if (window.currentAccount) {
      this.accountBadge = new dc.ui.AccountBadge(currentAccount);
      content.append(this.accountBadge.render().el);
    }
    
    this.titleEl = $('h1#title');
    
    this.setCallbacks();
    dc.history.loadURL();
  },
  
  // TEMP TEMP TEMP
  deselectTabs : function() {
    $('#navigation .nav').removeClass('active');
  },
  
  // TEMP TEMP TEMP
  showDocuments : function() {
    dc.app.searchBox.search(dc.app.searchBox.value());
  },
  
  // Show the document upload form.
  showUploadForm : function() {
    this.deselectTabs();
    $('#upload_nav').addClass('active');
    var docUpload = new dc.ui.DocumentUpload();
    this.sidebar.show(docUpload.helpContent());
    this.panel.show(docUpload.render().el);
    this.setTitle('Upload a Document');
  },
  
  setTitle : function(title) {
    this.titleEl.text(title);
    document.title = title + ' | DocumentCloud';
  }
  
});