dc.ui.LabelList = dc.View.extend({
  
  id : 'label_list',
  
  callbacks : [
    ['.divider.labels',   'click',    'toggleLabelMaker'],
    ['#new_label_button', 'click',    'saveNewLabel'],
    ['#new_label',        'keypress', 'saveNewLabel']
  ],
  
  constructor : function(options) {
    this.base(options);
    _.bindAll('ensurePopulated', '_addSavedSearch', '_addLabel', '_removeSubView', this);
    dc.app.navigation.register('documents', this.ensurePopulated);
    $(this.el).html(dc.templates.LABEL_LIST({}));
    this.labelsEl     = $('#labels', this.el);
    this.searchesEl   = $('#saved_searches', this.el);
    this.newLabelEl   = $('#new_label', this.el);
    this.setMode('collapsed', 'labels');
    this.setCallbacks();
    this._bindToSets();
  },
  
  ensurePopulated : function() {
    if (!SavedSearches.populated) SavedSearches.populate();
    if (!Labels.populated)        Labels.populate();
  },
  
  // Show/Hide the form for creating new Labels.
  toggleLabelMaker : function() {
    var next = this.modes.labels == 'expanded' ? 'collapsed' : 'expanded';
    this.setMode(next, 'labels');
  },
  
  warnAlreadyExists : function() {
    dc.ui.notifier.show({text : 'label already exists', anchor : this.newLabelEl, position : '-left bottom'});
  },
  
  saveNewLabel : function(e) {
    if (e.keyCode && e.keyCode != 13) return;
    var me = this;
    var input = this.newLabelEl;
    var title = input.val();
    if (!title) return;
    if (Labels.find(title)) return this.warnAlreadyExists();
    input.val(null);
    input.focus();
    var label = new dc.model.Label({title : title});
    Labels.create(label, null, {error : function() { Labels.remove(label); }});
  },
  
  // Bind all possible SavedSearch and Label events for rendering.
  _bindToSets : function() {
    SavedSearches.bind(dc.Set.MODEL_ADDED, this._addSavedSearch);
    SavedSearches.bind(dc.Set.MODEL_REMOVED, this._removeSubView);
    Labels.bind(dc.Set.MODEL_ADDED, this._addLabel);
    Labels.bind(dc.Set.MODEL_REMOVED, this._removeSubView);
  },
  
  _addSavedSearch : function(e, model) {
    this.searchesEl.append(new dc.ui.SavedSearch({model : model}).render().el);
  },
  
  _addLabel : function(e, model) {
    this.labelsEl.append(new dc.ui.Label({model : model}).render().el);
  },
  
  _removeSubView : function(e, model) {
    $(model.view.el).remove();
  }
  
});