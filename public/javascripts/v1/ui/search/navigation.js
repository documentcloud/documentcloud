// A tabbed navigation bar, relying on CSS rules to hide and show tabs.
dc.ui.Navigation = dc.View.extend({

  id            : 'navigation',
  currentTab    : null,
  tabCallbacks  : {},

  callbacks : [
    ['el',  'click',  'onTabClick']
  ],

  // List of tab names => page titles.
  tabs : [
    {name : 'search',    title : 'Search'},
    {name : 'upload',    title : 'Upload a Document'},
    {name : 'analyze',   title : 'Analyze'},
    {name : 'admin',     title : 'Manage Accounts'},
    {name : 'dashboard', title : 'Dashboard'}
  ],

  constructor : function(options) {
    this.base(options);
    this.enableTabURLs();
  },

  // Render the list of tabs that should be shown to the logged-in journalist.
  render : function() {
    var nav = this.el;
    _.each(this.tabs, function(tab) {
      var attrs = {id : tab.name + '_nav', tab : tab.name, title : tab.title, 'class' : 'nav'};
      $(nav).append($.el('div', attrs, Inflector.capitalize(tab.name)));
    });
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
    var el = $('#' + tab + '_nav', this.el);
    $('.nav', this.el).removeClass('active');
    el.addClass('active');
    this.setTitle(el.attr('title'));
    $(document.body).setMode(tab, 'navigation');
  },

  // Switch to a tab as an event callback.
  onTabClick : function(e) {
    if (!$(e.target).hasClass('nav')) return;
    var tab = $(e.target).attr('tab');
    var box = dc.app.searchBox;
    var fragment = tab == 'search' && box.fragment ? box.fragment : tab;
    dc.history.save(fragment);
    this.tab(tab);
  },

  // Add all of the tabs as history handlers.
  enableTabURLs : function() {
    var me = this;
    _.each(_.pluck(this.tabs, 'name'), function(tab) {
      dc.history.register(new RegExp('^#' + tab + '\\b'), _.bind(me.tab, me, tab));
    });
  },

  // Set the title of the page (both in HTML and the browser window).
  setTitle : function(title) {
    $('h1#title').text(title);
    document.title = title + ' - DocumentCloud';
  }

});
