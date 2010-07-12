dc.model.SelectableSet = Base.extend({

  SELECTION_CHANGED : 'set:selection_changed',

  firstSelection : null,

  selectedCount : 0,

  selectAll : function() {
    _.each(this.models(), function(m){ m.set({selected : true}); });
  },

  deselectAll : function() {
    _.each(this.models(), function(m){ m.set({selected : false}); });
  },

  selected : function() {
    return _.select(this.models(), function(m){ return m.get('selected'); });
  },

  selectedIds : function() {
    return _.pluck(this.selected(), 'id');
  },

  _add : function(model, silent) {
    model.set({'selected': !!model.get('selected')}, true);
    this.base(model, silent);
    if (model.get('selected')) this.selectedCount += 1;
  },

  _remove : function(model, silent) {
    this.base(model, silent);
    if (model.get('selected')) this.selectedCount -= 1;
  },

  // We override "_onModelEvent" to fire selection changed events when models
  // change their selected state.
  _onModelEvent : function(e, model) {
    this.base(e, model);
    var sel = (e == dc.Model.CHANGED && model.hasChanged('selected'));
    if (sel) {
      var selected = model.get('selected');
      if (selected && this.selectedCount == 0) {
        this.firstSelection = model;
      } else if (!selected && this.firstSelection == model) {
        this.firstSelection = null;
      }
      this.selectedCount += selected ? 1 : -1;
      _.defer(_(this.fire).bind(this, this.SELECTION_CHANGED, this));
    }
  }

});