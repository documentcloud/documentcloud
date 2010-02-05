// A tabbed navigation bar, relying on CSS rules to hide and show tabs.
dc.ui.Navigation = dc.View.extend({

  id            : 'navigation',
  currentTab    : null,
  tabCallbacks  : {},

  // List of tab names -> page titles.
  tabs : {
    search    : 'Search',
    upload    : 'Upload',
    analyze   : 'Analyze',
    accounts  : 'Manage Accounts',
    dashboard : 'Dashboard'
  },

  constructor : function() {
    this.enableTabURLs();
  },

  // Register tab changes to trigger callbacks.
  register : function(tabName, callback) {
    this.tabCallbacks[tabName] = this.tabCallbacks[tabName] || [];
    this.tabCallbacks[tabName].push(callback);
  },

  // Switch to a view by name. If silent, don't save the state change in the
  // browser's history.
  tab : function(tab, options) {
    options = options || {};
    this.section = options.section;
    this.inner   = options.inner;
    this.render();
    if (this.currentTab == tab) return;
    this.currentTab = tab;
    if (this.tabCallbacks[tab]) _.invoke(this.tabCallbacks[tab]);
    var box = dc.app.searchBox;
    var fragment = tab == 'search' && box.fragment ? box.fragment : tab;
    if (!options.silent) dc.history.save(fragment);
    this.setTitle(this.tabs[tab]);
    $(document.body).setMode(tab, 'navigation');
  },

  // Add all of the tabs as history handlers.
  enableTabURLs : function() {
    var me = this;
    _.each(this.tabs, function(obj, tab) {
      dc.history.register(new RegExp('^#' + tab + '\\b'), _.bind(me.tab, me, tab));
    });
  },

  // Set the title of the page (both in HTML and the browser window).
  setTitle : function(title) {
    $('h1#title').text(title);
    document.title = title + ' - DocumentCloud';
  }

});
