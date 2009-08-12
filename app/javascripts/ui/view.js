dc.ui.View = Base.extend({
  
  el : null,
  model : null,
  defaultOptions : {},
  callbacks : {},
  modes : null,
  className : 'view',
  _tagName : 'div',
  
  constructor : function(options) {
    this.modes = {};
    
    this.el = $.el(this._tagName, {'class' : this.className});  
    if (this._tagName.toUpperCase() == 'A') this.el.href = '#';
    
    this.configure(options);
    
    this.setCallbacks();
    // if(this.options.className) this.el.addClassName(this.options.className);
    // if(this.options.style) this.el.setStyle(this.options.style);
    // if(this.options.title) this.el.title = this.options.title;
    // if(this.options.id) this.el.id = this.options.id;
    return this;
  },
  
  configure : function(options) {
    // Need to clone and merge DEFAULT_OPTIONS and defaultOptions...
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
  
  setCallbacks : function() {
    var me = this;
    _.each(this.callbacks, function(triplet) {
      var selector = triplet[0], ev = triplet[1], methodName = triplet[2];
      var method = _.bind(me[methodName], me);
      $(selector, me.el).live(ev, method);
    });
  },
  
  cleanup : function() {
    // THINK ABOUT BASING ALL CALLBACKS ON LIVE_QUERY ... COULD GREATLY SIMPLIFY.
  }
  
}, {

  DEFAULT_OPTIONS : {
    className : null,
    id : null,
    style : null,
    title : null
  }

});
