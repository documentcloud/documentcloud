dc.ui.Tooltip = dc.View.extend({

  id : 'tooltip',

  OFFSET : 5,

  constructor : function() {
    this.base();
    this._open = false;
    _.bindAll(this, 'hide', 'show');
    $(document.body).append(this.el);
  },

  show : function(options) {
    this._open    = true;
    options       = _.extend(this.defaultOptions(), options);
    options.left += this.OFFSET;
    options.top  += this.OFFSET;
    this.setMode(options.mode, 'style');
    $(this.el).html(options.text)
              .fadeIn('fast')
              .css({top : options.top, left : options.left});
    $(document).bind('mouseover', this.hide);
  },

  hide : function() {
    if (!this._open) return;
    this._open = false;
    $(document).unbind('mouseover', this.hide);
    $(this.el).fadeOut('fast');
  },

  defaultOptions : function() {
    return {
      text      : 'info',
      left      : 0,
      top       : 0
    };
  }

});