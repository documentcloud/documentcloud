dc.ui.Notifier = dc.View.extend({

  id : 'notifier',

  callbacks : {
    'el.click': 'hide'
  },

  constructor : function() {
    this.base();
    this.defaultAnchor = $('#topbar')[0];
    $(document.body).append(this.el);
    _.bindAll(this, 'show', 'hide');
    this.setCallbacks();
  },

  // Display the notifier with a message, positioned relative to an optional
  // anchor element.
  show : function(options) {
    options = _.extend(this.defaultOptions(), options);
    this.setMode(options.mode, 'style');
    $(this.el).text(options.text).fadeIn('fast');
    $(this.el).show();
    if (this.timeout) clearTimeout(this.timeout);
    if (!options.leaveOpen) this.timeout = setTimeout(this.hide, options.duration);
  },

  hide : function(immediate) {
    this.timeout = null;
    immediate === true ? $(this.el).hide() : $(this.el).fadeOut('fast');
  },

  defaultOptions : function() {
    return {
      anchor    : this.defaultAnchor,
      position  : 'center center',
      text      : 'ok',
      left      : 0,
      top       : 0,
      duration  : 2000,
      leaveOpen : false,
      mode      : 'warn'
    };
  }

});