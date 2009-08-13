// Base provides a base class for our client-side models.
dc.Model = Base.extend({
  
  // A snapshot of the model's previous attributes, taken immediately
  // after the last CHANGED event was fired.
  _formerAttributes : null,
  
  // Has the item been changed since the last CHANGED event?
  _changed : false,
  
  // Create a new model, with defined attributes.
  // If you do not specify the id, a negative id will be assigned for you.
  constructor : function(attributes) {
    this._attributes = {};
    attributes = attributes || {};
    attributes.id = attributes.id || -_.uniqueId();
    this.set(attributes);
    this.cid = _.uniqueId('c');
    this._changed - false;
    this._formerAttributes = this.getAttributes();
  },
  
  // Create a new model with identical attributes to this one.
  clone : function() {
    return new (this.constructor)(this.getAttributes());
  },
  
  // Are this model's attributes identical to another model?
  isEqual : function(other) {
    return other && _.isEqual(this._attributes, other._attributes);
  },
  
  // Call this method to fire manually fire a CHANGED event for this model.
  // Calling this will cause all objects observing the model to update.
  changed : function() {
    this.fire(dc.Model.CHANGED, this);
    this._formerAttributes = this.getAttributes();
    this._changed = false;
    this._changedAttributes = false;
  },
  
  // Determine if the model has changed since the last CHANGED event.
  // If you specify an attribute name, determine if that attribute has changed.
  hasChanged : function(attr) {
    if (attr) return this._formerAttributes[attr] != this._attributes[attr];
    return this._changed;
  },
  
  // Get the previous value of an attribute, recorded at the time the last 
  // CHANGED event was fired.
  getFormerValue : function(attr) {
    if (!attr || !this._formerAttributes) return null;
    return this._formerAttributes[attr];
  },
  
  // Removes the former state, setting it to the state of the current attributes.
  resetFormerAttributes : function() {
    this._formerAttributes = this.getAttributes();
  },
  
  // Get all of the attributes of the model at the time of the previous 
  // CHANGED event.
  getFormerAttributes : function() {
    return this._formerAttributes;
  },
  
  // Return an object containing all the attributes that have changed. Useful
  // for determining what parts of a view need to be updated and/or what
  // attributes need to be persisted to the server.
  getChangedAttributes : function() {
    if (!this._formerAttributes) {
      var old = this.getFormerAttributes(), now = this.getAttributes();
      var changed = this._changedAttributes = {};
      for (var attr in now) {
        if (!_.isEqual(old[attr], now[attr])) changed[attr] = now[attr];
      }
    }
    return this._changedAttributes;
  },
  
  // Set a hash of model attributes on the object, firing CHANGED unless you
  // choose to silence it.
  set : function(obj, silent) {
    if (!obj) return;
    obj = obj._attributes || obj;
    for (var attr in obj) this._attributes[attr] = obj[attr];
    if (obj.id) this.id = obj.id;
    if (!silent) this.changed();
    return this;
  },
  
  // Get the value of an attribute.
  get : function(attr) {
    return this._attributes[attr];
  },
  
  // Remove an attribute from the model, firing CHANGED unless you choose to
  // silence it.
  unset : function(attr, silent) {
    var value = this._attributes[attr];
    delete this._attributes[attr];
    if (!silent) this.changed();
    return value;
  },
  
  // Return a copy of the model's attributes.
  getAttributes : function() {
    return _.clone(this._attributes);
  },
  
  toString : function() {
    return 'Model ' + this.id;
  } 
  
  // Think about adding all of the enumerable methods to Model.
  
}, {
  
  // Event fired when the model's properties have changed.
  CHANGED : 'model:changed'
  
});

dc.Model.implement(dc.util.Bindable.methods);