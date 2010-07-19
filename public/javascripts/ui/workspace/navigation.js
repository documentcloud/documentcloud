dc.ui.Navigation = dc.View.extend({

  SECTIONS : {
    projects  : 'sidebar',
    entities  : 'sidebar',
    documents : 'panel',
    help      : 'panel'
  },

  constructor : function() {
    this.base({el : document.body});
    _.bindAll(this, '_switchTab');
  },

  render : function() {
    this.tabs = _.reduce($('div.tab'), {}, _.bind(function(memo, el) {
      memo[$(el).attr('data-tab')] = $(el).click(this._switchTab);
      return memo;
    }, this));
    this.tabs[dc.app.preferences.get('sidebar_tab') || 'projects'].click();
    this.bind('entities', function() {
      _.defer(dc.app.searchBox.loadFacets);
    });
    this.bind('projects', _.bind(this._saveSidebarPreference, this, 'projects'));
    this.bind('entities', _.bind(this._saveSidebarPreference, this, 'entities'));
    this.setMode('documents', 'panel_tab');
    return this;
  },

  open : function(tab_name) {
    if (this.isOpen(tab_name)) return false;
    this.tabs[tab_name].click();
  },
  
  isOpen : function(tab_name) {
    return this.modes[this.SECTIONS[tab_name] + '_tab'] == tab_name;
  },

  bind : function(tab_name, callback) {
    this.tabs[tab_name].click(callback);
  },

  _switchTab : function(e) {
    var tab  = $(e.target).closest('.tab');
    var name = tab.attr('data-tab');
    $('.tab.active', $(e.target).closest('.tabs')).removeClass('active');
    tab.addClass('active');
    this.setMode(name, this.SECTIONS[name] + '_tab');
    _.defer(dc.app.scroller.check);
  },

  _saveSidebarPreference : function(kind) {
    dc.app.preferences.set({sidebar_tab : kind});
  }

});