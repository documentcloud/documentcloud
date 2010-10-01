// Mixin for collections which should be made selectable.
dc.model.Selectable = {

  firstSelection : null,

  selectedCount : 0,

  selectAll : function() {
    this.each(function(m){ m.set({selected : true}); });
  },

  deselectAll : function() {
    this.each(function(m){ m.set({selected : false}); });
  },

  selected : function() {
    return this.select(function(m){ return m.get('selected'); });
  },

  selectedIds : function() {
    return _.pluck(this.selected(), 'id');
  },

  _resetSelection : function() {
    this.firstSelection = null;
    this.selectedCount = 0;
  },

  _add : function(model, silent) {
    if (model._attributes.selected == null) model._attributes.selected = false;
    Backbone.Collection.prototype._add.call(this, model, silent);
    if (model.get('selected')) this.selectedCount += 1;
  },

  _remove : function(model, silent) {
    Backbone.Collection.prototype._remove.call(this, model, silent);
    if (this.selectedCount > 0 && model.get('selected')) this.selectedCount -= 1;
  },

  // We override "_onModelEvent" to fire selection changed events when models
  // change their selected state.
  _onModelEvent : function(ev, model) {
    Backbone.Collection.prototype._onModelEvent.call(this, ev, model);
    var sel = (ev == 'change' && model.hasChanged('selected'));
    if (sel) {
      var selected = model.get('selected');
      if (selected && this.selectedCount == 0) {
        this.firstSelection = model;
      } else if (!selected && this.firstSelection == model) {
        this.firstSelection = null;
      }
      this.selectedCount += selected ? 1 : -1;
      _.defer(_(this.fire).bind(this, 'select', this));
    }
  }

};