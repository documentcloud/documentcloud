dc.ui.Tooltip = dc.View.extend({

  id        : 'tooltip',
  className : 'interface',

  OFFSET    : 5,
  MAX_WIDTH : 320,

  constructor : function() {
    this.base();
    this._open = false;
    _.bindAll(this, 'hide', 'show');
    $(this.el).html(JST['common/tooltip']());
    this._title   = $('#tooltip_title', this.el);
    this._content = $('#tooltip_text', this.el);
    $(document.body).append(this.el);
  },

  show : function(options) {
    var limit = $(window).width() - this.OFFSET - this.MAX_WIDTH;
    options       = _.extend(this.defaultOptions(), options);
    options.top  += this.OFFSET;
    if (options.left < limit) {
      options.left += this.OFFSET;
    } else {
      options.left -= (this.MAX_WIDTH);
    }
    this.setMode(options.mode, 'style');
    this._title.html(options.title);
    this._content.html(options.text);
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
    $.browser.msie ? $(this.el).show() : $(this.el).stop(true, true).fadeIn('fast');
  },

  fadeOut : function() {
    $.browser.msie ? $(this.el).hide() : $(this.el).stop(true, true).fadeOut('fast');
  },

  defaultOptions : function() {
    return {
      text      : 'info',
      left      : 0,
      top       : 0
    };
  }

});