dc.ui.Navigation = dc.View.extend({

  SECTIONS : {
    projects  : 'sidebar',
    entities  : 'sidebar',
    documents : 'panel',
    help      : 'panel'
  },

  constructor : function() {
    this.base({el : document.body});
  },

  render : function() {
    this.tabs = _.reduce(_.keys(this.SECTIONS), _.bind(function(memo, name) {
      var el = $('#' + name + '_tab');
      memo[name] = el.click(_.bind(this._switchTab, this, name));
      return memo;
    }, this), {});
    this.tabs[dc.app.preferences.get('sidebar_tab') || 'projects'].click();
    this.bind('tab:projects', _.bind(this._saveSidebarPreference, this, 'projects'));
    this.bind('tab:entities', _.bind(this._saveSidebarPreference, this, 'entities'));
    this.bind('tab:entities', function() { _.defer(dc.app.searcher.loadFacets); });
    this.setMode('documents', 'panel_tab');
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
    if (!(silent === true)) this.fire('tab:' + name);
    _.defer(dc.app.scroller.check);
  },

  _saveSidebarPreference : function(kind) {
    dc.app.preferences.set({sidebar_tab : kind});
  }

});

dc.ui.Navigation.implement(dc.model.Bindable);
