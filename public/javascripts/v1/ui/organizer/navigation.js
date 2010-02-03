// A tabbed navigation bar, relying on CSS rules to hide and show tabs.
dc.ui.Navigation = dc.View.extend({

  id            : 'navigation',
  currentTab    : null,
  tabCallbacks  : {},

  home    : {name : 'Home', callback : function(){ dc.app.navigation.tab('dashboard'); }},
  section : null,
  inner   : null,

  // List of tab names -> page titles.
  tabs : {
    search    : 'Search',
    upload    : 'Upload',
    analyze   : 'Analyze',
    accounts  : 'Manage Accounts',
    dashboard : 'Dashboard'
  },

  constructor : function(options) {
    this.base(options);
    this.enableTabURLs();
  },

  // Render the list of tabs that should be shown to the logged-in journalist.
  render : function() {
    var el = $(this.el);
    el.html('');
    _.each(_.compact([this.home, this.section, this.inner]), function(link) {
      var linkEl = $.el('span', {}, link.name);
      if (link.callback) $(linkEl).bind('click', link.callback);
      el.append(linkEl);
      el.append(' &nbsp;&raquo;&nbsp; ');
    });
    return this;
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
