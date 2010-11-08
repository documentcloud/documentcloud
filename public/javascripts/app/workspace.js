// Main controller for the journalist workspace. Orchestrates subviews.
dc.controllers.Workspace = Backbone.Controller.extend({

  routes : {
    'help/:page': 'help',
    'help':       'help'
  },

  // Initializes the workspace, binding it to <body>.
  initialize : function() {
    this.el = $('body')[0];
    this.createSubViews();
    this.renderSubViews();
    dc.app.searcher = new dc.controllers.Searcher();
    if (!Backbone.history.start()) {
      dc.app.searcher.loadDefault({showHelp: true});
    }
  },

  help : function(page) {
    this.help.openPage(page);
  },

  // Create all of the requisite subviews.
  createSubViews : function() {
    dc.app.searchBox  = new dc.ui.SearchBox();
    dc.app.paginator  = new dc.ui.Paginator();
    dc.app.navigation = new dc.ui.Navigation();
    dc.app.toolbar    = new dc.ui.Toolbar();
    dc.ui.notifier    = new dc.ui.Notifier();
    dc.ui.tooltip     = new dc.ui.Tooltip();
    this.sidebar      = new dc.ui.Sidebar();
    this.panel        = new dc.ui.Panel();
    this.documentList = new dc.ui.DocumentList();
    this.entityList   = new dc.ui.EntityList();

    if (!dc.account) return;

    this.organizer    = new dc.ui.Organizer();
    dc.app.uploader   = new dc.ui.UploadDialog();
    dc.app.accounts   = new dc.ui.AccountDialog();
    this.accountBadge = new dc.ui.AccountView({model : Accounts.current(), kind : 'badge'});
  },

  // Render all of the existing subviews and place them in the DOM.
  renderSubViews : function() {
    var content   = $('#content');
    content.append(this.sidebar.render().el);
    content.append(this.panel.render().el);
    dc.app.navigation.render();
    dc.app.hotkeys.initialize();
    this.help = new dc.ui.Help({el : $('#help')[0]}).render();
    this.panel.add('search_box', dc.app.searchBox.render().el);
    this.panel.add('pagination', dc.app.paginator.el);
    this.panel.add('search_toolbar', dc.app.toolbar.render().el);
    this.panel.add('document_list', this.documentList.render().el);
    this.sidebar.add('entities', this.entityList.render().el);
    $('#no_results_container').html(JST['workspace/no_results']({}));

    if (!dc.account) return;

    this.sidebar.add('organizer', this.organizer.render().el);
    this.sidebar.add('account_badge', this.accountBadge.render().el);
  }

});
