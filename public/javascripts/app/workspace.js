// Main controller for the journalist workspace. Orchestrates subviews.
dc.app.workspace = new dc.View();
_.extend(dc.app.workspace, {
  
  // Initializes the workspace, binding it to <body>.
  initialize : function() {
    this.el = $('body')[0];
    this.createSubViews();
    this.renderSubViews();
    this.navigation.setTab('documents');
    dc.history.loadURL();
  },
  
  // Create all of the requisite subviews.
  createSubViews : function() {
    dc.app.searchBox  = new dc.ui.SearchBox();
    this.sidebar      = new dc.ui.Sidebar();
    this.panel        = new dc.ui.Panel();
    if (!window.currentAccount) return;
    this.navigation   = new dc.ui.Navigation();
    this.uploadForm   = new dc.ui.DocumentUpload();
    this.accountBadge = new dc.ui.AccountBadge(currentAccount);
  },
  
  // Render all of the existing subviews and place them in the DOM.
  renderSubViews : function() {
    var content   = $('#content');
    content.append(this.sidebar.render().el);
    content.append(this.panel.render().el);
    if (this.uploadForm) this.uploadForm.render();
    if (this.navigation) content.append(this.navigation.render().el);
    if (this.accountBadge) content.append(this.accountBadge.render().el);
  }
  
});