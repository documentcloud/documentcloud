dc.ui.View = Base.extend({
  
  el : null,
  model : null,
  defaultOptions : {},
  modes : null,
  klassName : 'dc.ui.View',
  _tagName : 'div',
  _callbacks : null,
  
  constructor : function(options) {
    this.modes = {};
    this._callbacks = {};
    
    // this.el = $.el(this._tagName, {'class' : className});
    // if (this._tagName.toLowerCase() == 'a') this.el.href = '#';
    
    this.configure(options);
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