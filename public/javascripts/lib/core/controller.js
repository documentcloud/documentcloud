dc.Controller = Base.extend({

  el        : null,
  model     : null,
  modes     : null,
  id        : null,
  className : null,
  callbacks : null,
  tagName   : 'div',

  constructor : function(options) {
    this.modes = {};
    this.configure(options || {});
    this.el = this.options.el || this._createElement();
    return this;
  },

  configure : function(options) {
    if (this.defaultOptions) options = _.extend(this.defaultOptions(), options);
    if (options.model)      this.model = options.model;
    if (options.set)        this.set = options.set;
    if (options.id)         this.id = options.id;
    if (options.className)  this.className = options.className;
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
    var me = this;
    $(me.el).unbind();
    _.each(callbacks || this.callbacks || {}, function(val, key) {
      key = key.split(/\.(?!.*\.)/);
      var selector = key[0], eventName = key[1], methodName = val;
      var method = _.bind(me[methodName], me);
      if (selector == 'el' || eventName == 'change') {
        $(me.el).bind(eventName, method);
      } else {
        $(me.el).delegate(selector, eventName, method);
      }
    });
    return this;
  },

  _createElement : function() {
    var attrs = {};
    if (this.id) attrs.id = this.id;
    if (this.className) attrs['class'] = this.className;
    return this.el = this.make(this.tagName, attrs);
  }

});
