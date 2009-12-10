dc.View = Base.extend({

  el              : null,
  model           : null,
  callbacks       : {},
  modes           : null,
  id              : null,
  className       : 'view',
  tagName         : 'div',

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

  children : function() {
    return [];
  },

  // Makes the view enter a mode. Modes have both a 'mode' and a 'group',
  // and are mutually exclusive with any other modes in the same group.
  // Setting will update the view's modes hash, as well as set an HTML className
  // of [mode]_[group] on the view's element. Convenient way to swap styles
  // and behavior.
  setMode : function(mode, group) {
    $(this.el).setMode(mode, group);
    this.modes[group] = mode;
  },

  // Set callbacks, where this.callbacks is an array of [CSS-selector,
  // event-name, callback-name] triplets. Callbacks will be bound to the view,
  // with 'this' set properly. Passing a selector of 'el' binds to the view's
  // element.
  setCallbacks : function(callbacks) {
    var me = this;
    _.each(callbacks || this.callbacks, function(triplet) {
      var selector = triplet[0], ev = triplet[1], methodName = triplet[2];
      var method = _.bind(me[methodName], me);
      (selector == 'el' ? $(me.el) : $(selector, me.el)).bind(ev, method);
    });
  }

});
