// DocumentCloud workspace hotkeys. To tell if a key is currently being pressed,
// just ask: `dc.app.hotkeys.control`
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