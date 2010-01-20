dc.ui.Organizer = dc.View.extend({

  id : 'organizer',

  callbacks : [],

  constructor : function(options) {
    this.base(options);
    _.bindAll(this, '_addSubView', '_removeSubView');
    this._bindToSets();
    this.sidebar = new dc.ui.OrganizerSidebar({organizer : this});
    this.subViews = [];
  },

  render : function() {
    dc.app.workspace.sidebar.add('organizer_sidebar', this.sidebar.render().el);
    this.setCallbacks();
    this.renderAll();
    return this;
  },

  renderAll : function() {
    this._renderMyDocuments();
    _.each(this.sortedModels(), _.bind(function(model) {
      this._addSubView(null, model);
    }, this));
  },

  _renderMyDocuments : function() {
    var view = new dc.ui.MyDocuments().render();
    this.subViews.push(view);
    $(this.el).prepend(view.el);
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
    this.sidebar.filterEl.val('');
    $('.box', this.el).show();
  },

  // Filters the visible labels and saved searches, by case-insensitive search.
  // Returns the number of visible items.
  autofilter : function(search, e) {
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

  models : function() {
    return _.flatten([Labels.models(), SavedSearches.models()]);
  },

  sortedModels : function() {
    return _.sortBy(this.models(), function(m){ return m.sortKey(); });
  },

  // Bind all possible SavedSearch, Bookmark and Label events for rendering.
  _bindToSets : function() {
    _.each([Labels, SavedSearches], _.bind(function(set) {
      set.bind(dc.Set.MODEL_ADDED, this._addSubView);
      set.bind(dc.Set.MODEL_REMOVED, this._removeSubView);
    }, this));
  },

  _addSubView : function(e, model) {
    var view = new dc.ui[model.viewClass]({model : model}).render();
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