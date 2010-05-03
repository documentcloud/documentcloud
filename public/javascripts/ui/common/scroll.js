dc.ui.Scroll = dc.View.extend({

  OVERLAP_MARGIN : 100,

  SPEED: 500,

  className : 'scroll',

  callbacks : {
    '.scroll_up.click'    : 'scrollUp',
    '.scroll_down.click'  : 'scrollDown'
  },

  // Given a div with overflow:hidden, make the div scrollable by inserting
  // "page up" and "page down" divs at the top and bottom.
  constructor : function(el) {
    this.base();
    this.content    = $(el);
    this.upButton   = $.el('div', {'class' : 'scroll_up'});
    this.downButton = $.el('div', {'class' : 'scroll_down'});
  },

  render : function() {
    this.content.addClass('scroll_content');
    this.content.wrap(this.el);
    this.el = $(this.content).closest('.scroll')[0];
    this.content.before(this.upButton);
    this.content.after(this.downButton);
    $(window).resize(_.bind(this.check, this));
    this.setCallbacks();
    return this;
  },

  scrollUp : function() {
    var distance = this.content.innerHeight() - this.OVERLAP_MARGIN;
    // var top = this.content[0].scrollTop;
    // if (top - distance < 0) distance = top;
    this.content.animate({scrollTop : this.content[0].scrollTop - distance}, this.SPEED);
  },

  scrollDown : function() {
    var distance = this.content.innerHeight() + this.OVERLAP_MARGIN;
    this.content.animate({scrollTop : this.content[0].scrollTop + distance}, this.SPEED);
  },

  check : function() {
    var over = this.hasOverflow();
    if (over == this._overflow) return;
    this._overflow = over;
    $(this.el).setMode(over ? 'is' : 'not', 'active');
  },

  hasOverflow : function() {
    return this.content.innerHeight() < this.content[0].scrollHeight;
  }

});