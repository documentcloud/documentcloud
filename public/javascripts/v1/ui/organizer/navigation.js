// A tabbed navigation bar, relying on CSS rules to hide and show tabs.
dc.ui.Navigation = dc.View.extend({

  id            : 'navigation',
  currentTab    : null,
  tabCallbacks  : {},

  callbacks : {
  },

  // List of tab names -> page titles.
  tabs : {
    search    : {title : 'Search'},
    upload    : {title : 'Upload a Document'},
    analyze   : {title : 'Analyze'},
    accounts  : {title : 'Manage Accounts'},
    dashboard : {title : 'Dashboard'}
  },

  constructor : function(options) {
    this.base(options);
    this.enableTabURLs();
  },

  // Render the list of tabs that should be shown to the logged-in journalist.
  render : function() {
    this.setCallbacks();
    return this;
  },

  // Register tab changes to trigger callbacks.
  register : function(tabName, callback) {
    this.tabCallbacks[tabName] = this.tabCallbacks[tabName] || [];
    this.tabCallbacks[tabName].push(callback);
  },

  // Switch to a tab by name.
  tab : function(tab) {
    if (this.currentTab == tab) return;
    this.currentTab = tab;
    if (this.tabCallbacks[tab]) _.invoke(this.tabCallbacks[tab]);
    var box = dc.app.searchBox;
    var fragment = tab == 'search' && box.fragment ? box.fragment : tab;
    dc.history.save(fragment);
    this.setTitle(this.tabs[tab].title);
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
