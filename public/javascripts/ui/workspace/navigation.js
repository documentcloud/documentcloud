dc.ui.Navigation = Backbone.View.extend({

  SECTIONS : {
    documents : 'sidebar',
    entities  : 'sidebar',
    search    : 'panel',
    help      : 'panel',
    publish   : 'panel'
  },

  VALID : {
    sidebar : ['documents', 'accounts'],
    panel   : ['search', 'publish', 'help']
  },

  constructor : function() {
    Backbone.View.call(this, {el : document.body});
  },

  render : function() {
    this.tabs = _.reduce(_.keys(this.SECTIONS), _.bind(function(memo, name) {
      var el = $('#' + name + '_tab');
      memo[name] = el.click(_.bind(this._switchTab, this, name));
      return memo;
    }, this), {});
    this.tabs['documents'].click();
    this.bind('tab:entities', _.bind(function() {
      if (!this.isOpen('search')) this.open('search');
      // _.defer(dc.app.searcher.loadFacets);
    }, this));
    $('#toplinks .open_accounts').click(function(){ dc.app.accounts.open(); });
    this.setMode('search', 'panel_tab');
    return this;
  },

  open : function(tab_name, silent) {
    if (this.isOpen(tab_name)) return false;
    this._switchTab(tab_name, silent);
  },

  isOpen : function(tab_name) {
    return this.modes[this.SECTIONS[tab_name] + '_tab'] == tab_name;
  },

  _switchTab : function(name, silent) {
    var tab  = this.tabs[name];
    $('.tab.active', $(tab).closest('.tabs')).removeClass('active');
    tab.addClass('active');
    this.setMode(name, this.SECTIONS[name] + '_tab');
    if (!(silent === true)) this.trigger('tab:' + name);
    _.defer(dc.app.scroller.check);
  }

});

_.extend(dc.ui.Navigation.prototype, Backbone.Events);
