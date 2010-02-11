dc.View = Base.extend({

  el              : null,
  model           : null,
  callbacks       : {},
  modes           : null,
  id              : null,
  className       : 'view',
  tagName         : 'div',

  // Match the last period in a string.
  LAST_DOT        : /\.(?!.*\.)/,

  constructor : function(options) {
    this.modes = {};
    this.configure(options || {});
    this.el = this.options.el || $.el(this.tagName, {id : this.id, 'class' : this.className});
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

  setOptions : function(options) {
    this.options = _.extend(this.options, options);
    return this;
  },

  render : function() {
    return this;
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

  // Set callbacks, where this.callbacks is a hash of {selector.event_name,
  // callback_name] pairs. Callbacks will be bound to the view,
  // with 'this' set properly. Passing a selector of 'el' binds to the view's
  // element.
  setCallbacks : function(callbacks) {
    var me = this;
    _.each(callbacks || this.callbacks, function(val, key) {
      key = key.split(me.LAST_DOT);
      var selector = key[0], eventName = key[1], methodName = val;
      var method = _.bind(me[methodName], me);
      (selector == 'el' ? $(me.el) : $(selector, me.el)).bind(eventName, method);
    });
  }

});
