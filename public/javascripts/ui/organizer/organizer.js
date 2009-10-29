dc.ui.Organizer = dc.View.extend({
  
  id : 'organizer',
  
  callbacks : [],
  
  constructor : function(options) {
    this.base(options);
    _.bindAll('ensurePopulated', '_addLabel', '_addSavedSearch', '_removeSubView', this);
    dc.app.navigation.register('organize', this.ensurePopulated);
    this._bindToSets();
    this.sidebar = new dc.ui.OrganizerSidebar();
  },
  
  render : function() {
    dc.app.workspace.sidebar.add('organizer_sidebar', this.sidebar.render().el);
    this.setCallbacks();
    return this;
  },
  
  ensurePopulated : function() {
    if (!SavedSearches.populated) SavedSearches.populate();
    if (!Labels.populated)        Labels.populate();
  },
  
  // Bind all possible SavedSearch and Label events for rendering.
  _bindToSets : function() {
    SavedSearches.bind(dc.Set.MODEL_ADDED, this._addSavedSearch);
    SavedSearches.bind(dc.Set.MODEL_REMOVED, this._removeSubView);
    Labels.bind(dc.Set.MODEL_ADDED, this._addLabel);
    Labels.bind(dc.Set.MODEL_REMOVED, this._removeSubView);
  },
  
  _addSavedSearch : function(e, model) {
    this._addSubView(new dc.ui.SavedSearch({model : model}).render());
  },
  
  _addLabel : function(e, model) {
    this._addSubView(new dc.ui.Label({model : model}).render());
  },
  
  _addSubView : function(view) {
    var models = Labels.models().concat(SavedSearches.models());
    models = _.sortBy(models, function(m){ return m.sortKey(); });
    var previous = models[_.indexOf(models, view.model) - 1];
    var previousView = previous && previous.view;
    if (!previous || !previousView) return $(this.el).append(view.el);
    $(previousView.el).after(view.el);
  },
  
  _removeSubView : function(e, model) {
    $(model.view.el).remove();
  }
  
});