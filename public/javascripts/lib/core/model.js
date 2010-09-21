// Base provides a base class for our client-side models.
dc.Model = Base.extend({

  // A snapshot of the model's previous attributes, taken immediately
  // after the last `model:changed` event was fired.
  _formerAttributes : null,

  // Has the item been changed since the last `model:changed` event?
  _changed : false,

  // Create a new model, with defined attributes.
  // If you do not specify the id, a negative id will be assigned for you.
  constructor : function(attributes) {
    this._attributes = {};
    attributes = attributes || {};
    attributes.id = attributes.id || -_.uniqueId();
    this.set(attributes, true);
    this.cid = _.uniqueId('c');
    this._formerAttributes = this.attributes();
  },

  // Create a new model with identical attributes to this one.
  clone : function() {
    return new (this.constructor)(this.attributes());
  },

  // Are this model's attributes identical to another model?
  isEqual : function(other) {
    return other && _.isEqual(this._attributes, other._attributes);
  },

  // A model is new if it has never been saved to the server, and has a negative
  // ID.
  isNew : function() {
    return this.id < 0;
  },

  // Call this method to fire manually fire a `model:changed` event for this model.
  // Calling this will cause all objects observing the model to update.
  changed : function() {
    this.fire('model:changed', this);
    this._formerAttributes = this.attributes();
    this._changed = false;
  },

  // Determine if the model has changed since the last `model:changed` event.
  // If you specify an attribute name, determine if that attribute has changed.
  hasChanged : function(attr) {
    if (attr) return this._formerAttributes[attr] != this._attributes[attr];
    return this._changed;
  },

  // Get the previous value of an attribute, recorded at the time the last
  // `model:changed` event was fired.
  formerValue : function(attr) {
    if (!attr || !this._formerAttributes) return null;
    return this._formerAttributes[attr];
  },

  // Get all of the attributes of the model at the time of the previous
  // `model:changed` event.
  formerAttributes : function() {
    return this._formerAttributes;
  },

  // Return an object containing all the attributes that have changed, or false
  // if there are no changed attributes. Useful for determining what parts of a
  // view need to be updated and/or what attributes need to be persisted to
  // the server.
  changedAttributes : function(now) {
    var old = this.formerAttributes(), now = now || this.attributes(), changed = false;
    for (var attr in now) {
      if (!_.isEqual(old[attr], now[attr])) {
        changed = changed || {};
        changed[attr] = now[attr];
      }
    }
    return changed;
  },

  // Set a hash of model attributes on the object, firing `model:changed` unless you
  // choose to silence it.
  set : function(next, silent) {
    if (!next) return this;
    next = next._attributes || next;
    var now = this._attributes;
    for (var attr in next) {
      var val = next[attr];
      if (val === '') val = null;
      if (!_.isEqual(now[attr], val)) {
        if (!silent) this._changed = true;
        now[attr] = val;
      }
    }
    if (next.id) this.id = next.id;
    if (!silent && this._changed) this.changed();
    return this;
  },

  // Get the value of an attribute.
  get : function(attr) {
    return this._attributes[attr];
  },

  // Remove an attribute from the model, firing `model:changed` unless you choose to
  // silence it.
  unset : function(attr, silent) {
    var value = this._attributes[attr];
    delete this._attributes[attr];
    if (!silent) this.changed();
    return value;
  },

  // Return a copy of the model's attributes.
  attributes : function() {
    return _.clone(this._attributes);
  },

  toString : function() {
    return 'Model ' + this.id;
  }

  // Think about adding all of the enumerable methods to Model.

}, {

  // Comparator (the default for SortedSets) that simply compares ids.
  ID_COMPARATOR : function(m) {
    return m.id;
  }

});

dc.Model.implement(dc.model.Bindable);