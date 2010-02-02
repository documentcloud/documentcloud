// A tabbed navigation bar, relying on CSS rules to hide and show tabs.
dc.ui.Navigation = dc.View.extend({

  id            : 'navigation',
  currentTab    : null,
  tabCallbacks  : {},

  callbacks : {
    'button.back.click': 'back'
  },

  home    : $.el('a', {href : '#dashboard'}, 'home'),
  section : null,
  inner   : null,

  // List of tab names -> page titles.
  tabs : {
    search    : {title : 'Search',              back : 'Back to the Dashboard'},
    upload    : {title : 'Upload a Document',   back : 'Back to the Documents'},
    analyze   : {title : 'Analyze',             back : 'Back to the Documents'},
    accounts  : {title : 'Manage Accounts',     back : 'Back to the Dashboard'},
    dashboard : {title : 'Dashboard',           back : ''}
  },

  constructor : function(options) {
    this.base(options);
    this.enableTabURLs();
  },

  // Render the list of tabs that should be shown to the logged-in journalist.
  render : function() {
    var el = $(this.el);
    el.html('');
    _.each(_.compact([this.home, this.section, this.inner]), function(part) {
      el.append(part);
      el.append(' &raquo; ');
    });
    this.setCallbacks();
    return this;
  },

  // Register tab changes to trigger callbacks.
  register : function(tabName, callback) {
    this.tabCallbacks[tabName] = this.tabCallbacks[tabName] || [];
    this.tabCallbacks[tabName].push(callback);
  },

  // Switch to a view by name. If silent, don't save the state change in the
  // browser's history.
  tab : function(tab, silent) {
    if (this.currentTab == tab) return;
    this.currentTab = tab;
    this.render();
    if (this.tabCallbacks[tab]) _.invoke(this.tabCallbacks[tab]);
    var box = dc.app.searchBox;
    var fragment = tab == 'search' && box.fragment ? box.fragment : tab;
    if (!silent) dc.history.save(fragment);
    this.setTitle(this.tabs[tab].title);
    $(document.body).setMode(tab, 'navigation');
  },

  // Go back out a level from the current tab.
  back : function() {
    window.history.back();
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
