dc.View = Base.extend({
  
  el              : null,
  model           : null,
  defaultOptions  : {},
  callbacks       : {},
  modes           : null,
  id              : null,
  className       : 'view',
  tagName         : 'div',
  
  constructor : function(options) {
    options = options || {};
    this.modes = {};
    this.el = options.el || $.el(this.tagName, {id : this.id, 'class' : this.className});  
    this.configure(options);
    
    // if(this.options.className) this.el.addClassName(this.options.className);
    // if(this.options.style) this.el.setStyle(this.options.style);
    // if(this.options.title) this.el.title = this.options.title;
    // if(this.options.id) this.el.id = this.options.id;
    return this;
  },
  
  configure : function(options) {
    // Need to clone and merge DEFAULT_OPTIONS and defaultOptions...
    if (options.model) this.model = options.model;
    this.options = options;
  },
  
  setOptions : function(options) {
    this.options = $.extend(this.options, options);
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
    $.setMode(this.el, mode, group);
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
  
}, {

  DEFAULT_OPTIONS : {
    className : null,
    id : null,
    style : null,
    title : null
  }

});
