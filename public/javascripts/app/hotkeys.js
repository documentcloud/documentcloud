// DocumentCloud workspace hotkeys. To tell if a key is currently being pressed,
// just ask: `dc.app.hotkeys.control`
dc.app.hotkeys = {

  KEYS: {
    '16':  'shift',
    '17':  'control',
    '91':  'command',
    '93':  'command',
    '224': 'command',
    '13':  'enter',
    '37':  'left',
    '38':  'upArrow',
    '39':  'right',
    '40':  'downArrow',
    '46':  'delete',
    '8':   'backspace',
    '9':   'tab',
    '188': 'comma'
  },

  initialize : function() {
    _.bindAll(this, 'down', 'up', 'blur');
    $(document).bind('keydown', this.down);
    $(document).bind('keyup', this.up);
    $(window).bind('blur', this.blur);
  },

  down : function(e) {
    var key = this.KEYS[e.which];
    if (key) this[key] = true;
  },

  up : function(e) {
    var key = this.KEYS[e.which];
    if (key) this[key] = false;
  },

  blur : function(e) {
    for (var key in this.KEYS) this[this.KEYS[key]] = false;
  },
  
  key : function(e) {
    return this.KEYS[e.keyCode || e.which];
  },
  
  colon : function(e) {
    var charCode = e.keyCode || e.which;
    return charCode && String.fromCharCode(charCode) == ":";
  }

};