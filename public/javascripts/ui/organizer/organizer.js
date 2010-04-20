dc.ui.Organizer = dc.View.extend({

  id : 'organizer',

  callbacks : {
    '#new_project.click'      : 'promptNewProject',
    '#upload_document.click'  : 'openUploads',
    '#projects_tab.click'     : 'showProjects',
    '#entities_tab.click'     : 'showEntities'
  },

  constructor : function(options) {
    this.base(options);
    _.bindAll(this, '_addSubView', '_removeSubView', 'openUploads', 'filterFacet');
    this._bindToSets();
    $('#logo').remove();
    this.subViews = [];
  },

  render : function() {
    $(this.el).append(JST.organizer_sidebar({}));
    this.projectInputEl = $('#project_input', this.el);
    this.projectList    = $('.project_list', this.el);
    this.entityList     = $('#organizer_entities', this.el);
    this.renderAll();
    this.showProjects();
    this.setCallbacks();
    return this;
  },

  renderAll : function() {
    if (Projects.empty()) this.setMode('no', 'projects');
    $(this.projectList).append((new dc.ui.Project()).render().el);
    _.each(Projects.models(), _.bind(function(model) {
      this._addSubView(null, model);
    }, this));
  },

  showProjects : function() {
    this.setMode('projects', 'active');
  },

  showEntities : function() {
    this.setMode('entities', 'active');
  },

  renderFacets : function(facets) {
    this.entityList.html(JST.organizer_entities({entities: facets}));
    $('.facet', this.entityList).bind('click', this.filterFacet);
  },

  clickSelectedItem : function() {
    $(this.selectedItem.el).trigger('click');
  },

  select : function(view) {
    $(view.el).addClass('gradient_selected');
    this.selectedItem = view;
  },

  deselect : function() {
    if (this.selectedItem) $(this.selectedItem.el).removeClass('gradient_selected');
    this.selectedItem = null;
  },

  clear : function() {
    this.deselect();
    $('.box', this.projectList).show();
  },

  filterFacet : function(e) {
    var el = $(e.target);
    var val = el.attr('data-value');
    if (val.match(/\s/)) val = '"' + val + '"';
    var fragment = $(e.target).attr('data-category') + ': ' + val;
    dc.app.searchBox.addToSearch(fragment);
  },

  promptNewProject : function() {
    var me = this;
    dc.ui.Dialog.prompt('Create a New Project', '', function(title) {
      if (!title) return;
      if (Projects.find(title)) return me._warnAlreadyExists();
      var project = new dc.model.Project({title : title, annotation_count : 0, document_ids : []});
      Projects.create(project, null, {error : function() { Projects.remove(project); }});
      return true;
    }, 'short');
  },

  openUploads : function() {
    dc.app.uploader.open();
  },

  // Bind all possible and Project events for rendering.
  _bindToSets : function() {
    _.each([Projects], _.bind(function(set) {
      set.bind(dc.Set.MODEL_ADDED, this._addSubView);
      set.bind(dc.Set.MODEL_REMOVED, this._removeSubView);
    }, this));
  },

  _warnAlreadyExists : function() {
    dc.ui.notifier.show({text : 'project already exists', anchor : $('div.dialog input.content'), position : 'bottom -left', top : 16});
    return false;
  },

  _addSubView : function(e, model) {
    this.setMode('has', 'projects');
    var view = new dc.ui.Project({model : model}).render();
    this.subViews.push(view);
    var models = Projects.models();
    var previous = models[_.indexOf(models, view.model) - 1];
    var previousView = previous && previous.view;
    if (!previous || !previousView) { return $(this.projectList).append(view.el); }
    $(previousView.el).after(view.el);
  },

  _removeSubView : function(e, model) {
    this.subViews = _.without(this.subViews, model.view);
    $(model.view.el).remove();
  }

});
