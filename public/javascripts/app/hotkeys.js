// DocumentCloud workspace hotkeys. For now, just needs to track if
// shift is being held down, for shift-clicks.
dc.app.hotkeys = {

  KEYS: {
    '16':  'shift',
    '17':  'control',
    '91':  'command',
    '93':  'command',
    '224': 'command'
  },

  initialize : function() {
    _.bindAll(this, 'down', 'up', 'blur');
    $(document).bind('keydown', this.down);
    $(document).bind('keyup', this.up);
    $(window).bind('blur', this.blur);
  },

  down : function(e) {
    var key = this.KEYS[e.keyCode];
    if (key) this[key] = true;
  },

  up : function(e) {
    var key = this.KEYS[e.keyCode];
    if (key) this[key] = false;
  },

  blur : function(e) {
    for (key in this.KEYS) this[this.KEYS[key]] = false;
  }

};