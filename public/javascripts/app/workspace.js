// Main controller for the journalist workspace. Orchestrates subviews.
dc.app.workspace = new dc.View();
_.extend(dc.app.workspace, {
  
  // Initializes the workspace, binding it to <body>.
  initialize : function() {
    this.el = $('body')[0];
    this.createSubViews();
    this.renderSubViews();
    if (dc.app.navigation) dc.app.navigation.tab('documents');
    dc.history.loadURL();
  },
  
  // Create all of the requisite subviews.
  createSubViews : function() {
    dc.app.searchBox  = new dc.ui.SearchBox();
    dc.ui.notifier    = new dc.ui.Notifier();
    this.sidebar      = new dc.ui.Sidebar();
    this.panel        = new dc.ui.Panel();
    
    if (!dc.app.accountId) return;
    
    dc.app.navigation = new dc.ui.Navigation();
    this.uploadForm   = new dc.ui.DocumentUpload();
    this.accountBadge = new dc.ui.AccountView(Accounts.current(), 'badge');
    this.accountList  = new dc.ui.AccountList();
  },
  
  // Render all of the existing subviews and place them in the DOM.
  renderSubViews : function() {
    var content   = $('#content');
    content.append(this.sidebar.render().el);
    content.append(this.panel.render().el);
    
    if (!dc.app.accountId) return;
    
    this.uploadForm.render();
    this.panel.add('accounts_panel', this.accountList.render().el);
    content.append(dc.app.navigation.render().el);
    content.append(this.accountBadge.render().el);
  }
  
});