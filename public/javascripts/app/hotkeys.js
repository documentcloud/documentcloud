// DocumentCloud workspace hotkeys. For now, just needs to track if
// shift is being held down, for shift-clicks.
dc.app.hotkeys = {

  KEYS: {
    shift   : 16,
    command : 91
  },

  initialize : function() {
    _.bindAll(this, 'down', 'up', 'blur');
    $(document).bind('keydown', this.down);
    $(document).bind('keyup', this.up);
    $(window).bind('blur', this.blur);
  },

  down : function(e) {
    // console.log(e.keyCode);
    for (key in this.KEYS) if (e.keyCode == this.KEYS[key]) this[key] = true;
  },

  up : function(e) {
    for (key in this.KEYS) if (e.keyCode == this.KEYS[key]) this[key] = false;
  },

  blur : function(e) {
    for (key in this.KEYS) this[key] = false;
  }

};