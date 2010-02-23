dc.ui.ProjectMenu = dc.ui.Menu.extend({

  constructor : function(options) {
    _.bindAll(this, 'renderProjects');
    options = _.extend({
      id          : 'projects_menu',
      label       : 'Projects',
      onOpen      : this.renderProjects,
      onClose     : this._shouldClose,
      autofilter  : true,
      autoAdd     : 'create a new project'
    }, options);
    this.base(options);
  },

  renderProjects : function(menu) {
    menu.clear();
    var docs = Documents.selected();
    menu.addItems(_.map(Projects.models(), function(project) {
      var className = project.containsAny(docs) ? 'icon bullet_yellow' : 'icon bullet_white';
      return {title : project.get('title'), className : className, onClick : _.bind(menu.options.onClick, menu, project)};
    }));
  },

  _shouldClose : function(e) {
    return e && !$(e.target).hasClass('autofilter_input');
  }

});