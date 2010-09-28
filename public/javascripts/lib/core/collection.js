(function(){

  // **Collection** provides a standard collection class for our sets of models, ordered
  // or unordered. If a `comparator` is specified, the Set will maintain its
  // models in sort order.
  dc.Collection = Base.extend({

    // Create a new dc.Collection.
    constructor : function(options) {
      this._boundOnModelEvent = _.bind(this._onModelEvent, this);
      this._initialize();
    },

    // Initialize or re-initialize all internal state.
    _initialize : function() {
      this.length = 0;
      this.models = [];
      this._byId = {};
      this._byCid = {};
    },

    // Get a model from the set by id.
    get : function(id) {
      return id && this._byId[id.id || id];
    },

    // Get a model from the set by client id.
    getByCid : function(cid) {
      return cid && this._byCid[cid.cid || cid];
    },

    // What are the ids for every model in the set?
    getIds : function() {
      return _.keys(this._byId);
    },

    // What are the client ids for every model in the set?
    getCids : function() {
      return _.keys(this._byCid);
    },

    // Get the model at the given index.
    at: function(index) {
      return this.models[index];
    },

    // Add a model, or list of models to the set. Pass silent to avoid firing
    // the `set:added` event for every new model.
    add : function(models, silent) {
      if (!_.isArray(models)) return this._add(models, silent);
      for (var i=0; i<models.length; i++) this._add(models[i], silent);
      return models;
    },

    // Internal implementation of adding a single model to the set.
    _add : function(model, silent) {
      var already = this.get(model);
      if (already) throw new Error(["Can't add the same model to a set twice", already.id]);
      this._byId[model.id] = model;
      this._byCid[model.cid] = model;
      var index = this.comparator ? this.sortedIndex(model, this.comparator) : this.length - 1;
      this.models.splice(index, 0, model);
      model.bind('all', this._boundOnModelEvent);
      this.length++;
      if (!silent) this.fire('set:added', model);
      return model;
    },

    // Remove a model, or a list of models from the set. Pass silent to avoid
    // firing the `set:removed` event for every model removed.
    remove : function(models, silent) {
      if (!_.isArray(models)) return this._remove(models, silent);
      for (var i=0; i<models.length; i++) this._remove(models[i], silent);
      return models;
    },

    // Internal implementation of removing a single model from the set.
    _remove : function(model, silent) {
      model = this.get(model);
      if (!model) return null;
      delete this._byId[model.id];
      delete this._byCid[model.cid];
      this.models.splice(this.indexOf(model), 1);
      model.unbind('all', this._boundOnModelEvent);
      this.length--;
      if (!silent) this.fire('set:removed', model);
      return model;
    },

    // When you have more items than you want to add or remove individually,
    // you can refresh the entire set with a new list of models, without firing
    // any `set:added` or `set:removed` events. Fires `set:refreshed` when finished.
    refresh : function(models, silent) {
      models = models || [];
      if (models[0] && !(models[0] instanceof dc.Model)) {
        for (var i = 0, l = models.length; i < l; i++) {
          models[i] = new this.model(models[i]);
        }
      }
      this._initialize();
      this.add(models, true);
      if (!silent) this.fire('set:refreshed');
    },

    // Force the set to re-sort itself. You don't need to call this under normal
    // circumstances, as the set will maintain sort order as each item is added.
    sort : function(silent) {
      if (!this.comparator) throw new Error('Cannot sort a set without a comparator');
      this.models = this.sortBy(this.comparator);
      if (!silent) this.fire('set:refreshed');
    },

    // Internal method called every time a model in the set fires an event.
    // Sets need to update their indexes when models change ids.
    _onModelEvent : function(e, model) {
      if (e == 'model:changed') {
        if (model.hasChanged('id')) {
          delete this._byId[model.formerValue('id')];
          this._byId[model.id] = model;
        }
        this.fire('model:changed', model);
      }
    },

    // Inspect.
    toString : function() {
      return 'Set (' + this.length + " models)";
    }

  });

  // Underscore methods that we want to implement on the Set.
  var methods = ['each', 'map', 'reduce', 'reduceRight', 'detect', 'select',
    'reject', 'all', 'any', 'include', 'invoke', 'pluck', 'max', 'min', 'sortBy',
    'sortedIndex', 'toArray', 'size', 'first', 'rest', 'last', 'without',
    'indexOf', 'lastIndexOf', 'isEmpty'];

  // Mix in each Underscore method as a proxy to `Set#models`.
  _.each(methods, function(method) {
    dc.Collection.prototype[method] = function() {
      return _[method].apply(_, [this.models].concat(_.toArray(arguments)));
    };
  });

  dc.Collection.implement(dc.model.Bindable);

})();