dc.Controller = Base.extend({

  el        : null,
  model     : null,
  modes     : null,
  id        : null,
  className : null,
  callbacks : null,
  options   : null,
  tagName   : 'div',

  constructor : function(options) {
    this.modes = {};
    this.configure(options || {});
    if (this.options.el) {
      this.el = this.options.el;
    } else {
      var attrs = {};
      if (this.id) attrs.id = this.id;
      if (this.className) attrs['class'] = this.className;
      this.el = this.make(this.tagName, attrs);
    }
    return this;
  },

  configure : function(options) {
    if (this.options) options = _.extend({}, this.options, options);
    if (options.model)      this.model      = options.model;
    if (options.collection) this.collection = options.collection;
    if (options.id)         this.id         = options.id;
    if (options.className)  this.className  = options.className;
    this.options = options;
  },

  render : function() {
    return this;
  },

  // jQuery lookup, scoped to the current view.
  $ : function(selector) {
    return $(selector, this.el);
  },

  // Quick-create a dom element with attributes.
  make : function(tagName, attributes, content) {
    var el = document.createElement(tagName);
    if (attributes) $(el).attr(attributes);
    if (content) $(el).html(content);
    return el;
  },

  // Makes the view enter a mode. Modes have both a 'mode' and a 'group',
  // and are mutually exclusive with any other modes in the same group.
  // Setting will update the view's modes hash, as well as set an HTML className
  // of [mode]_[group] on the view's element. Convenient way to swap styles
  // and behavior.
  setMode : function(mode, group) {
    if (this.modes[group] == mode) return;
    $(this.el).setMode(mode, group);
    this.modes[group] = mode;
  },

  // Set callbacks, where this.callbacks is a hash of
  //   {selector.event_name, callback_name}
  // pairs. Callbacks will be bound to the view, with 'this' set properly.
  // Passing a selector of 'el' binds to the view's root element.
  // Change events are not delegated through the view because IE does not bubble
  // change events at all.
  setCallbacks : function(callbacks) {
    $(this.el).unbind();
    if (!(callbacks || (callbacks = this.callbacks))) return this;
    for (key in callbacks) {
      var methodName = callbacks[key];
      key = key.split(/\.(?!.*\.)/);
      var selector = key[0], eventName = key[1];
      var method = _.bind(this[methodName], this);
      if (selector === '' || eventName == 'change') {
        $(this.el).bind(eventName, method);
      } else {
        $(this.el).delegate(selector, eventName, method);
      }
    }
    return this;
  }

});
