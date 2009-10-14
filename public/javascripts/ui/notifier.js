dc.ui.Notifier = dc.View.extend({
  
  id : 'notifier',
  duration : 2000,
  
  callbacks : [
    ['el',   'click',  'hide']
  ],
  
  constructor : function() {
    this.base();
    this.defaultAnchor = $('#topbar')[0];
    $(document.body).append(this.el);
    _.bindAll('show', 'hide', this);
    this.setCallbacks();
  },
  
  // Display the notifier with a message, positioned relative to an optional
  // anchor element.
  show : function(options) {
    options = _.extend(this.defaultOptions(), options);
    this.setMode(options.mode, 'style');
    $(this.el).text(options.text).fadeIn('fast');
    $.align(this.el, options.anchor, options.position, options);
    if (!options.leaveOpen) setTimeout(this.hide, this.duration);
  },
  
  hide : function() {
    $(this.el).fadeOut('fast');
  },
  
  defaultOptions : function() {
    return {
      anchor    : this.defaultAnchor,
      position  : 'center center',
      text      : 'ok',
      left      : 0,
      top       : 0,
      leaveOpen : false,
      mode      : 'warn'
    };
  }
  
});