dc.ui.ProjectMenu = dc.ui.Menu.extend({

  constructor : function(options) {
    _.bindAll(this, 'renderProjects');
    options = _.extend({
      id          : 'projects_menu',
      label       : 'Projects',
      onOpen      : this.renderProjects
    }, options);
    this.base(options);
  },

  renderProjects : function(menu) {
    menu.clear();
    var docs  = Documents.selected();
    var items = _.map(Projects.models(), function(project, i) {
      var className = project.containsAny(docs) ? 'checked' : '';
      return {title : project.get('title'), className : className, onClick : _.bind(menu.options.onClick, menu, project)};
    });
    items.push({title : 'New Project', className : 'plus', onClick : function() {
      dc.app.workspace.organizer.promptNewProject();
    }});
    menu.addItems(items);
  }

});