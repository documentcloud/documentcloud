dc.ui.OrganizerSidebar = dc.View.extend({

  id : 'organizer_sidebar',

  callbacks : [
    ['#new_project_button', 'click',    'saveNewProject'],
    ['#project_input',      'keyup',    'onProjectInput'],
    ['#filter_box',         'keyup',    'autofilter']
  ],

  constructor : function(options) {
    this.base(options);
    this.organizer = this.options.organizer;
  },

  render : function() {
    $(this.el).append(JST.organizer_sidebar({}));
    this.projectInputEl = $('#project_input', this.el);
    this.filterEl = $('#filter_box', this.el);
    this.setCallbacks();
    return this;
  },

  autofilter : function(e) {
    this.organizer.autofilter(this.filterEl.val(), e);
  },

  onProjectInput : function(e) {
    if (e.keyCode && e.keyCode === 13) return this.saveNewProject(e);
  },

  saveNewProject : function(e) {
    var me = this;
    var input = this.projectInputEl;
    var title = input.val();
    if (!title) return;
    if (Projects.find(title)) return this.warnAlreadyExists();
    input.val(null);
    input.focus();
    this.organizer.autofilter('');
    var project = new dc.model.Project({title : title});
    Projects.create(project, null, {error : function() { Projects.remove(project); }});
  },

  warnAlreadyExists : function() {
    dc.ui.notifier.show({text : 'project already exists', anchor : this.projectInputEl, position : '-left bottom', top : 6, left : 1});
  }

});

