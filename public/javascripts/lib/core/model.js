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
  set : function(attrs, options) {
    options || (options = {});
    if (!attrs) return this;
    attrs = attrs._attributes || attrs;
    var now = this._attributes;
    if (attrs.collection) {
      this.collection = attrs.collection;
      delete attrs.collection;
      this.resource = this.collection.resource + '/' + this.id;
    }
    if (attrs.id) {
      this.id = attrs.id;
      if (this.collection) this.resource = this.collection.resource + '/' + this.id;
    }
    for (var attr in attrs) {
      var val = attrs[attr];
      if (val === '') val = null;
      if (!_.isEqual(now[attr], val)) {
        if (!options.silent) this._changed = true;
        now[attr] = val;
      }
    }
    if (!options.silent && this._changed) this.changed();
    return this;
  },

  // Get the value of an attribute.
  get : function(attr) {
    return this._attributes[attr];
  },

  // Remove an attribute from the model, firing `model:changed` unless you choose to
  // silence it.
  unset : function(attr, options) {
    options || (options = {});
    var value = this._attributes[attr];
    delete this._attributes[attr];
    if (!options.silent) this.changed();
    return value;
  },

  // Set a hash of model attributes, and sync the model to the server.
  save : function(attrs, options) {
    if (!this.resource) throw new Error(this.toString() + " cannot be saved without a resource.");
    options || (options = {});
    this.set(attrs, options);
    var model = this;
    $.ajax({
      url       : this.resource,
      type      : 'PUT',
      data      : {model : JSON.stringify(this.attributes())},
      dataType  : 'json',
      success   : function(resp) {
        model.set(resp.model);
        if (options.success) options.success(model, resp);
      },
      error     : function(resp) { if (options.error) options.error(model, resp); }
    });
  },

  // Return a copy of the model's attributes.
  attributes : function() {
    return _.clone(this._attributes);
  },

  // Bind all methods in the list to the model.
  bindAll : function() {
    _.bindAll.apply(_, [this].concat(arguments));
  },

  toString : function() {
    return 'Model ' + this.id;
  },

  // Destroy this model on the server.
  destroy : function(options) {
    if (this.collection) this.collection.remove(this);
    $.ajax({
      url       : this.resource,
      type      : 'DELETE',
      data      : {},
      dataType  : 'json',
      success   : function(resp) { if (options.success) options.success(model, resp); },
      error     : function(resp) { if (options.error) options.error(model, resp); }
    });
  }

}, {

  // Create a model on the server and add it to the set.
  // When the server returns a JSON representation of the model, we update it
  // on the client.
  create : function(attributes, options) {
    options || (options = {});
    var model = new this(attributes);
    $.ajax({
      url       : model.set.resource,
      type      : 'POST',
      data      : {model : JSON.stringify(model.attributes())},
      dataType  : 'json',
      success   : function(resp) {
        model.set(resp.model);
        if (options.success) return options.success(model, resp);
      },
      error     : function(resp) {
        if (options.error) options.error(model, resp);
      }
    });
  }

});

dc.Model.implement(dc.model.Bindable);