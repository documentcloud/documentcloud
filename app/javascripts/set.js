// Set provides a standard collection class for our pools of models.
dc.Set = Base.extend({
  
  // Create a new dc.Set.
  constructor : function() {
    this._boundOnModelEvent = _.bind(this._onModelEvent, this);
    this._initialize();
    // Consider adding filtering to the set.
  },
  
  // Initialize or re-initialize all internal state.
  _initialize : function() {
    this._size = 0;
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
  
  // How many models are in the set?
  size : function() {
    return this._size;
  },
  
  // Is a given model already present in the set?
  include : function(model) {
    return !!this._byId[model.id];
  },
  
  // Add a model, or list of models to the set. Pass silent to avoid firing
  // the MODEL_ADDED event for every new model.
  add : function(models, silent) {
    if (!_.isArray(models)) return this._add(models, silent);
    for (var i=0; i<models.length; i++) this._add(models[i], silent);
    return models;
  },
  
  // Internal implementation of adding a single model to the set.
  _add : function(model, silent) {
    var already = this.get(model);
    if (already) throw new Error("Can't add the same model to a set twice");
    this._byId[model.id] = model;
    this._byCid[model.cid] = model;
    model.bind(dc.util.Bindable.ALL, this._boundOnModelEvent, this);
    this._size++;
    if (!silent) this.fire(dc.Set.MODEL_ADDED, model);
    return model;
  },
  
  // Remove a model, or a list of models from the set. Pass silent to avoid
  // firing the MODEL_REMOVED event for every model removed.
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
    model.unbind(null, null, this);
    this._size--;
    if (!silent) this.fire(dc.Set.MODEL_REMOVED, model);
    return model;
  },
  
  // When you have more items than you want to add or remove individually, 
  // you can refresh the entire set with a new list of models, without firing
  // any MODEL_ADDED or MODEL_REMOVED events. Fires REFRESHED when finished.
  refresh : function(models, silent) {
    models = models || [];
    this._initialize();
    this.add(models, true);
    if (!silent) this.fire(dc.Set.REFRESHED);
  },
  
  // Internal method called every time a model in the set fires an event.
  _onModelEvent : function(e, model) {
    if (e == dc.Model.CHANGED) this.fire(dc.Set.MODEL_CHANGED, this, model);
  },
  
  // Inspect.
  toString : function() {
    return 'Set (' + this._size + " models)";
  }
  
}, {
  
  // Event fired when an individual model inside the set has changed.
  MODEL_CHANGED : 'set:model_changed',
  
  // Event fired when a model has been added to the set.
  MODEL_ADDED : 'set:model_added',
  
  // Event fired when a model has been removed from the set.
  MODEL_REMOVED : 'set:model_removed',
  
  // Event fired when enough of the set has changed that it wouldn't be 
  // efficient to go through every change individually. Views probably want
  // to handle this event by refreshing themselves.
  REFRESHED : 'set:refreshed'
  
});

dc.Set.implement(dc.util.Bindable.methods);