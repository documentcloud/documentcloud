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
    this.bind('projects', _.bind(this._saveSidebarPreference, this, 'projects'));
    this.bind('entities', _.bind(this._saveSidebarPreference, this, 'entities'));
    this.setMode('documents', 'panel_tab');
    this._helpToolbar = $('#help_toolbar');
    this._helpToolbar.prepend(this._createHelpMenu().render().el);
    return this;
  },

  open : function(name) {
    if (this.modes[this.SECTIONS[name] + '_tab'] == name) return false;
    this.tabs[name].click();
  },

  bind : function(name, callback) {
    this.tabs[name].click(callback);
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
  },

  _createHelpMenu : function() {
    var open = function(e){
      var resource = $(e.target).attr('data-rel');
      $.get("/help/" + resource + '.html', function(resp) {
        $('#help_content').html(resp);
      });
    };
    return this._helpMenu = new dc.ui.Menu({
      id      : 'how_to_menu',
      label   : 'Guides &amp; How To\'s',
      items   : [
        {title : 'Search Documents',        attrs: {'data-rel' : 'search'},       onClick : open},
        {title : 'Add Users',               attrs: {'data-rel' : 'add_users'},    onClick : open},
        {title : 'Upload Documents',        attrs: {'data-rel' : 'import'},       onClick : open},
        {title : 'Annotate',                attrs: {'data-rel' : 'notes'},        onClick : open},
        {title : 'Embed &amp; Publish',     attrs: {'data-rel' : 'publish'},      onClick : open},
        {title : 'Troubleshoot Documents',  attrs: {'data-rel' : 'troubleshoot'}, onClick : open}
      ]
    });
  }

});