dc.ui.Dialog = dc.View.extend({

  className : 'dialog',

  DEFAULT_OPTIONS : {
    title       : "Untitled Dialog",
    text        : null,
    information : null,
    choices     : null,
    password    : false,
    editor      : false
  },

  callbacks : {
    '.cancel.click':  'cancel',
    '.ok.click':      'confirm'
  },

  constructor : function(options) {
    this.base(options);
    if (this.options.mode) this.setMode(this.options.mode, 'dialog');
    _.bindAll(this, 'close', '_maybeConfirm');
  },

  render : function(opts) {
    opts = opts || {};
    $(this.el).html(JST.dialog(_.extend({}, this.options, opts)));
    var cel = this.contentEl = $('.content', this.el);
    this.controlsEl = $('.controls', this.el);
    this.controlsInner = $('.controls_inner', this.el);
    if (this.options.width) $(this.el).css({width : this.options.width});
    if (this.options.content) cel.val(this.options.content);
    $(document.body).append(this.el);
    this.center();
    this.setCallbacks();
    if (this._returnCloses()) $(document.body).bind('keypress', this._maybeConfirm);
    if (cel[0]) _.defer(function(){ cel.focus(); });
    if (!opts.noOverlay) $(document.body).addClass('overlay');
    return this;
  },

  setCallbacks : function(callbacks) {
    this.base(callbacks);
    $(this.el).draggable();
  },

  defaultOptions : function() {
    return _.clone(this.DEFAULT_OPTIONS);
  },

  append : function(el) {
    this.controlsEl.before(el);
  },

  appendControl : function(el) {
    this.controlsInner.append(el);
  },

  val : function() {
    return this.contentEl.val();
  },

  cancel : function() {
    if (this.options.onCancel) this.options.onCancel(this);
    this.close();
  },

  error : function(message) {
    $('.information', this.el).addClass('error').text(message);
  },

  confirm : function() {
    if (this.options.onConfirm && !this.options.onConfirm(this)) return false;
    this.close();
  },

  close : function() {
    if (this.options.onClose) this.options.onClose(this);
    $(this.el).remove();
    if (this._returnCloses()) $(document.body).unbind('keypress', this._maybeConfirm);
    $(document.body).removeClass('overlay');
  },

  center : function() {
    $(this.el).align(window, '', {top : -100});
  },

  _returnCloses : function() {
    return this.options.mode == 'alert' || this.options.mode == 'short_prompt';
  },

  _maybeConfirm : function(e) {
    if (e.keyCode == 13) this.confirm();
  }

}, {

  alert : function(text, options) {
    return new dc.ui.Dialog(_.extend({
      mode  : 'alert',
      title : null,
      text  : text
    }, options)).render();
  },

  prompt : function(text, content, callback, options) {
    var onConfirm = callback && function(dialog){ return callback(dialog.val()); };
    return new dc.ui.Dialog(_.extend({
      mode      : 'prompt',
      password  : !!(options && options.password),
      title     : text,
      text      : '',
      content   : content,
      onConfirm : onConfirm
    }, options)).render();
  },

  confirm : function(text, callback, options) {
    return new dc.ui.Dialog(_.extend({
      mode      : 'confirm',
      title     : null,
      text      : text,
      onConfirm : callback
    }, options)).render();
  },

  choose : function(text, choices, callback, options) {
    return new dc.ui.Dialog(_.extend({
      mode      : 'short_prompt',
      title     : text,
      choices   : choices,
      text      : '',
      onConfirm : callback && function(dialog){ return callback(dialog.val()); }
    }, options)).render();
  }

});