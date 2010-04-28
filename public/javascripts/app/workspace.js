// Main controller for the journalist workspace. Orchestrates subviews.
dc.app.workspace = new dc.View();
_.extend(dc.app.workspace, {

  // Initializes the workspace, binding it to <body>.
  initialize : function() {
    this.el = $('body')[0];
    this.createSubViews();
    this.renderSubViews();
    dc.history.initialize();
    dc.history.loadURL(function() {
      if (dc.app.documentCount) {
        Accounts.current().openDocuments();
      } else if (Projects.first()) {
        Projects.first().open();
      }
    });
  },

  // Create all of the requisite subviews.
  createSubViews : function() {
    dc.app.searchBox  = new dc.ui.SearchBox();
    dc.app.paginator  = new dc.ui.Paginator();
    dc.ui.notifier    = new dc.ui.Notifier();
    dc.ui.tooltip     = new dc.ui.Tooltip();
    this.sidebar      = new dc.ui.Sidebar();
    this.panel        = new dc.ui.Panel();

    if (!dc.app.accountId) return;

    dc.app.toolbar    = new dc.ui.Toolbar({tab : 'search'});
    dc.app.uploader   = new dc.ui.UploadDialog();
    dc.app.accounts   = new dc.ui.AccountDialog();
    dc.app.visualizer = new dc.ui.Visualizer();
    dc.app.entities   = new dc.ui.Entities();
    this.documentList = new dc.ui.DocumentList();
    this.accountBadge = new dc.ui.AccountView({model : Accounts.current(), kind : 'badge'});
    this.organizer    = new dc.ui.Organizer();
  },

  // Render all of the existing subviews and place them in the DOM.
  renderSubViews : function() {
    var content   = $('#content');
    content.append(this.sidebar.render().el);
    content.append(this.panel.render().el);
    this.panel.add('search_box', dc.app.searchBox.render().el);
    this.panel.add('pagination', dc.app.paginator.el);
    $('#no_results_container').html(JST.no_results({}));

    if (!dc.app.accountId) return $(document.body).setMode('search', 'navigation');

    dc.app.hotkeys.initialize();
    this.sidebar.add('account_badge', this.accountBadge.render().el);
    this.sidebar.add('organizer', this.organizer.render().el);
    dc.app.uploader.render();
    this.panel.add('document_list', this.documentList.render().el);
    this.panel.add('search_toolbar', dc.app.toolbar.render().el);
    $('#wordmark a').attr({href : '#help'});
  }

});