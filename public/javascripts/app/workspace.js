// Main controller for the journalist workspace. Orchestrates subviews.
dc.app.workspace = new dc.View();
_.extend(dc.app.workspace, {

  // Initializes the workspace, binding it to <body>.
  initialize : function() {
    this.el = $('body')[0];
    this.createSubViews();
    this.renderSubViews();
    dc.history.loadURL({fallback : 'search'});
  },

  // Create all of the requisite subviews.
  createSubViews : function() {
    dc.app.searchBox  = new dc.ui.SearchBox();
    dc.app.paginator  = new dc.ui.Paginator();
    dc.app.metaList   = new dc.ui.MetadataList();
    dc.ui.notifier    = new dc.ui.Notifier();
    dc.ui.query       = new dc.ui.Query();
    this.sidebar      = new dc.ui.Sidebar();
    this.panel        = new dc.ui.Panel();

    if (!dc.app.accountId) return;

    dc.app.navigation = new dc.ui.Navigation();
    dc.app.toolbar    = new dc.ui.Toolbar({tab : 'search'});
    this.uploadForm   = new dc.ui.DocumentUpload();
    this.accountBadge = new dc.ui.AccountView(Accounts.current(), 'badge');
    this.accountList  = new dc.ui.AccountList();
    this.organizer    = new dc.ui.Organizer();
    this.visualizer   = new dc.ui.Visualizer();
  },

  // Render all of the existing subviews and place them in the DOM.
  renderSubViews : function() {
    var content   = $('#content');
    content.append(this.sidebar.render().el);
    content.append(this.panel.render().el);
    this.panel.add('pagination', dc.app.paginator.el);
    $('#query_container').append(dc.ui.query.el);

    if (!dc.app.accountId) return;

    content.append(dc.app.navigation.render().el);
    content.append(this.accountBadge.render().el);
    this.uploadForm.render();
    this.panel.add('accounts_panel', this.accountList.render().el);
    this.panel.add('search_toolbar', dc.app.toolbar.render().el);
    this.panel.add('organizer', this.organizer.render().el);
    this.panel.add('visualizer', this.visualizer.render().el);
    dc.app.searchBox.addSaveSearchButton();
    this.warnNonWebkit();
  },

  // For now, the prototype only supports webkit-based browsers.
  warnNonWebkit : function() {
    if (!$.browser.safari) dc.ui.notifier.show({text : 'please use a webkit-based browser'});
  }

});