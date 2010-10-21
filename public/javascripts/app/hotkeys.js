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
    $(document).unbind('keydown.dc').bind('keydown.dc', this.down);
    $(document).unbind('keyup.dc').bind('keyup.dc', this.up);
    $(window).unbind('blur.dc').bind('blur.dc', this.blur);
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
    for (var key in this.KEYS) this[this.KEYS[key]] = false;
  }

};