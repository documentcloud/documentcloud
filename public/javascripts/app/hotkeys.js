// DocumentCloud workspace hotkeys. For now, just needs to track if
// shift is being held down, for shift-clicks.
dc.app.hotkeys = {

  SHIFT : 16,

  shift : false,

  initialize : function() {
    _.bindAll(this, 'down', 'up', 'blur');
    $(document).bind('keydown', this.down);
    $(document).bind('keyup', this.up);
    $(window).bind('blur', this.blur);
  },

  down : function(e) {
    if (e.keyCode == this.SHIFT) this.shift = true;
  },

  up : function(e) {
    if (e.keyCode == this.SHIFT) this.shift = false;
  },

  blur : function(e) {
    this.shift = false;
  }

};