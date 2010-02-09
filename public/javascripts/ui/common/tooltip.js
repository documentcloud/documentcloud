dc.ui.Tooltip = dc.View.extend({

  id        : 'tooltip',

  OFFSET : 5,

  constructor : function() {
    this.base();
    this._open = false;
    _.bindAll(this, 'hide', 'show');
    $(this.el).append($.el('div', {id: 'tooltip_background', 'class' : 'gradient_white'}));
    $(this.el).append($.el('div', {id: 'tooltip_text'}));
    this.content = $('#tooltip_text', this.el);
    $(document.body).append(this.el);
  },

  show : function(options) {
    options       = _.extend(this.defaultOptions(), options);
    options.left += this.OFFSET;
    options.top  += this.OFFSET;
    this.setMode(options.mode, 'style');
    this.content.html(options.text);
    $(this.el).css({top : options.top, left : options.left});
    if (!this._open) this.fadeIn();
    $(document).bind('mouseover', this.hide);
    this._open    = true;
  },

  hide : function() {
    if (!this._open) return;
    this._open = false;
    $(document).unbind('mouseover', this.hide);
    this.fadeOut();
  },

  fadeIn : function() {
    $.browser.msie ? $(this.el).show() : $(this.el).fadeIn('fast');
  },

  fadeOut : function() {
    $.browser.msie ? $(this.el).hide() : $(this.el).fadeOut('fast');
  },

  defaultOptions : function() {
    return {
      text      : 'info',
      left      : 0,
      top       : 0
    };
  }

});