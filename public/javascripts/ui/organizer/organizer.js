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
    $(this.el).append(new dc.ui.SavedSearch({model : model}).render().el);
  },
  
  _addLabel : function(e, model) {
    $(this.el).append(new dc.ui.Label({model : model}).render().el);
  },
  
  _removeSubView : function(e, model) {
    $(model.view.el).remove();
  }
  
});