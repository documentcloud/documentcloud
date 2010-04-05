dc.model.SelectableSet = Base.extend({

  SELECTION_CHANGED : 'set:selection_changed',

  lastSelection : null,

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

  countSelected : function() {
    return this.selected().length;
  },

  // We override "_onModelEvent" to fire selection changed events when models
  // change their selected state.
  _onModelEvent : function(e, model) {
    this.base(e, model);
    var sel = (e == dc.Model.CHANGED && model.hasChanged('selected'));
    if (sel) {
      if (model.get('selected')) {
        this.lastSelection = model;
      } else if (model == this.lastSelection) {
        this.lastSelection = null;
      }
      _.defer(_(this.fire).bind(this, this.SELECTION_CHANGED, this));
    }
  }

});