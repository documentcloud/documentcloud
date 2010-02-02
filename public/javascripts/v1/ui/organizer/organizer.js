dc.ui.Organizer = dc.View.extend({

  id : 'organizer',

  callbacks : {
    '#new_project_button.click': 'saveNewProject',
    '#project_input.keyup':      'onProjectInput',
    '#filter_box.keyup':         'autofilter'
  },

  constructor : function(options) {
    this.base(options);
    _.bindAll(this, '_addSubView', '_removeSubView');
    this._bindToSets();
    this.subViews = [];
  },

  render : function() {
    $(this.el).append(JST.organizer_sidebar({}));
    this.projectInputEl = $('#project_input', this.el);
    this.filterEl = $('#filter_box', this.el);
    this.projectList = $('.project_list', this.el);
    this.renderAll();
    this.setCallbacks();
    return this;
  },

  renderAll : function() {
    this._renderMyDocumentsAndNotes();
    _.each(this.sortedModels(), _.bind(function(model) {
      this._addSubView(null, model);
    }, this));
  },

  _renderMyDocumentsAndNotes : function() {
    var docs      = new dc.ui.MyDocuments().render();
    var notes     = new dc.ui.MyNotes().render();
    this.subViews = this.subViews.concat([docs, notes]);
    $(this.projectList).prepend($([docs.el, notes.el]));
  },

  clickSelectedItem : function() {
    $(this.selectedItem.el).trigger('click');
  },

  select : function(view) {
    $(view.el).addClass('selected');
    this.selectedItem = view;
  },

  deselect : function() {
    if (this.selectedItem) $(this.selectedItem.el).removeClass('selected');
    this.selectedItem = null;
  },

  clear : function() {
    this.deselect();
    this.filterEl.val('');
    $('.box', this.projectList).show();
  },

  // Filters the visible projects and saved searches, by case-insensitive search.
  // Returns the number of visible items.
  autofilter : function(e) {
    var search = this.filterEl.val();
    if (e && e.keyCode == 13) this.clickSelectedItem();
    var count = 0;
    var matcher = new RegExp(search, 'i');
    this.deselect();
    _.each(this.subViews, _.bind(function(view) {
      var sortKey = view.sortKey || view.model.sortKey();
      var selected = !!sortKey.match(matcher);
      $(view.el).toggle(selected);
      if (!search || !selected) return;
      count++;
      if (!this.selectedItem) this.select(view);
    }, this));
    // $(document.body).setMode(count === 0 ? 'empty' : 'no', 'search');
    return count;
  },

  saveNewProject : function(e) {
    var me = this;
    var input = this.projectInputEl;
    var title = input.val();
    if (!title) return;
    if (Projects.find(title)) return this._warnAlreadyExists();
    input.val(null);
    input.focus();
    this.organizer.autofilter('');
    var project = new dc.model.Project({title : title});
    Projects.create(project, null, {error : function() { Projects.remove(project); }});
  },

  models : function() {
    return _.flatten([Projects.models(), SavedSearches.models()]);
  },

  sortedModels : function() {
    return _.sortBy(this.models(), function(m){ return m.sortKey(); });
  },

  // Bind all possible SavedSearch and Project events for rendering.
  _bindToSets : function() {
    _.each([Projects, SavedSearches], _.bind(function(set) {
      set.bind(dc.Set.MODEL_ADDED, this._addSubView);
      set.bind(dc.Set.MODEL_REMOVED, this._removeSubView);
    }, this));
  },

  _onProjectInput : function(e) {
    if (e.keyCode && e.keyCode === 13) return this.saveNewProject(e);
  },

  _warnAlreadyExists : function() {
    dc.ui.notifier.show({text : 'project already exists', anchor : this.projectInputEl, position : '-left bottom', top : 6, left : 1});
  },

  _addSubView : function(e, model) {
    var view = new dc.ui[model.viewClass]({model : model}).render();
    this.subViews.push(view);
    var models = this.sortedModels();
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
