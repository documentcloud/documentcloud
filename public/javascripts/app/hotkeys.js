dc.app.hotkeys = {

  SHIFT : 16,

  shift : false,

  initialize : function() {
    _.bindAll(this, 'down', 'up');
    $(document).bind('keydown', this.down);
    $(document).bind('keyup', this.up);
  },

  down : function(e) {
    if (e.keyCode == this.SHIFT) this.shift = true;
  },

  up : function(e) {
    if (e.keyCode == this.SHIFT) this.shift = false;
  }

};