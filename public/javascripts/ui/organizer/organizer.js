dc.ui.Organizer = dc.View.extend({
  
  id : 'organizer',
  
  callbacks : [],
  
  constructor : function(options) {
    this.base(options);
    _.bindAll('ensurePopulated', '_addLabel', '_addSavedSearch', '_removeSubView', this);
    dc.app.navigation.register('organize', this.ensurePopulated);
    this._bindToSets();
    this.sidebar = new dc.ui.OrganizerSidebar({organizer : this});
    this.subViews = [];
  },
  
  render : function() {
    dc.app.workspace.sidebar.add('organizer_sidebar', this.sidebar.render().el);
    this.setCallbacks();
    return this;
  },
  
  // Filters the visible labels and saved searches, by case-insensitive search.
  // Returns the number of visible items.
  autofilter : function(search) {
    var count = 0;
    var matcher = new RegExp(search, 'i');
    _.each(this.subViews, function(view) {
      var selected = !!view.model.sortKey().match(matcher);
      if (selected) count++;
      $(view.el).toggle(selected);
    });
    return count;
  },
  
  ensurePopulated : function() {
    if (!SavedSearches.populated) SavedSearches.populate();
    if (!Labels.populated)        Labels.populate();
  },
  
  models : function() {
    return Labels.models().concat(SavedSearches.models());
  },
  
  sortedModels : function() {
    return _.sortBy(this.models(), function(m){ return m.sortKey(); });
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
    this.subViews.push(view);
    var models = this.sortedModels();
    var previous = models[_.indexOf(models, view.model) - 1];
    var previousView = previous && previous.view;
    if (!previous || !previousView) { return $(this.el).append(view.el); }
    $(previousView.el).after(view.el);
  },
  
  _removeSubView : function(e, model) {
    this.subViews = _.without(this.subViews, model.view);
    $(model.view.el).remove();
  }
  
});