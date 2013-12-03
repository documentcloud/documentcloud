dc.ui.ProjectMenu = dc.ui.Menu.extend({

  constructor : function(options) {
    _.bindAll(this, 'renderProjects');
    options = _.extend({
      id          : 'projects_menu',
      label       : 'Projects',
      onOpen      : this.renderProjects
    }, options);
    dc.ui.Menu.call(this, options);
  },

  renderProjects : function(menu) {
    menu.clear();
    var docs      = Documents.selected();
    var disabled  = !docs.length ? ' disabled' : '';
    var items     = Projects.map(function(project, i) {
      var className = (project.containsAny(docs) ? 'checked' : '') + disabled;
      return {title : project.get('title'), attrs : {'class': className}, onClick : _.bind(menu.options.onClick, menu, project)};
    });
    items.unshift({title : 'New Project', attrs : {'class' : 'plus'}, onClick : function() {
      dc.app.organizer.promptNewProject();
    }});
    menu.addItems(items);
  }

});