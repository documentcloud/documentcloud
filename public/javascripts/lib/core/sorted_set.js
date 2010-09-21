// A Set subclass for sets that should maintain sorted state, as determined by a
// comparator that you define. The comparator should take two dc.Models
// and return -1, 0, or 1 to reflect their sorted positions.
// To use it, call yourSet.implement(dc.model.SortedSet);
dc.model.SortedSet = dc.Set.extend({

  // Pass in the comparator function when you create a new SortedSet.
  constructor : function(comparator) {
    this.base();
    this.setComparator(comparator || this.comparator, true);
  },

  // Overrides _init to add a _byIndex index.
  _initialize : function() {
    this.base();
    this._byIndex = [];
  },

  // Specify the comparator by which to sort this set. Invokes sort().
  // Sorting the set will fire `set:refreshed` unless you choose to silence it.
  setComparator : function(comparator, silent) {
    comparator = comparator || dc.Model.ID_COMPARATOR;
    if (this.comparator == comparator) return;
    this.comparator = comparator;
    this.sort(silent);
  },

  // Force the set to re-sort itself. You don't need to call this under normal
  // circumstances, as the set will maintain sort order as each item is added.
  sort : function(silent) {
    this._byIndex = _.sortBy(this._byIndex, this.comparator);
    if (!silent) this.fire('set:refreshed');
  },

  // Overridden. Add an item to the SortedSet, keeping sort order.
  _add : function(model, silent) {
    if (model = this.base(model, true)) {
      var index = _.sortedIndex(this._byIndex, model, this.comparator);
      this._byIndex.splice(index, 0, model);
      if (!silent) this.fire('set:added', model);
    }
    return model;
  },

  // Overridden. Remove an item from the SortedSet.
  _remove : function(model, silent) {
    if (model = this.base(model, true)) {
      this._byIndex = _.without(this._byIndex, model);
      if (!silent) this.fire('set:removed', model);
    }
    return model;
  },

  // Loop over each model in the SortedSet in order.
  _each : function(iterator) {
    return _.each(this._byIndex, iterator);
  },

  // Get the index of a model.
  indexOf : function(model) {
    return _.indexOf(this._byIndex, model);
  },

  // Get the model at a specified position.
  getModelAt : function(index) {
    return this._byIndex[index];
  },

  models : function() {
    return this._byIndex;
  },

  first : function() {
    return _.first(this._byIndex);
  },

  last : function() {
    return _.last(this._byIndex);
  }

});