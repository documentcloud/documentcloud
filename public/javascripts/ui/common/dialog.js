dc.ui.Dialog = Backbone.View.extend({

  className : 'dialog',

  options : {
    title       : "Untitled Dialog",
    text        : null,
    information : null,
    description : null,
    choices     : null,
    password    : false,
    editor      : false,
    draggable   : true
  },

  callbacks : {
    '.cancel.click'   : 'cancel',
    '.ok.click'       : 'confirm',
    'input.focus'     : '_addFocus',
    'textarea.focus'  : '_addFocus',
    'input.blur'      : '_removeFocus',
    'textarea.blur'   : '_removeFocus'
  },

  render : function(opts) {
    opts = opts || {};
    if (this.options.mode) this.setMode(this.options.mode, 'dialog');
    if (this.options.draggable) this.setMode('is', 'draggable');
    _.bindAll(this, 'close');
    $(this.el).html(JST['common/dialog'](_.extend({}, this.options, opts)));
    var cel = this.contentEl = this.$('.content');
    this._controls = this.$('.controls');
    this._controlsInner = this.$('.controls_inner');
    this._information = this.$('.information');
    if (this.options.width) $(this.el).css({width : this.options.width});
    if (this.options.content) cel.val(this.options.content);
    $(document.body).append(this.el);
    this.center();
    this.setCallbacks();
    if (this._returnCloses()) $(document.body).bind('keypress', _.bind(this._maybeConfirm, this));
    if (cel[0]) _.defer(function(){ cel.focus(); });
    if (!opts.noOverlay) $(document.body).addClass('overlay');
    return this;
  },

  setCallbacks : function(callbacks) {
    Backbone.View.prototype.setCallbacks.call(this, callbacks);
    if (this.options.draggable) $(this.el).draggable();
  },

  append : function(el) {
    this._controls.before(el);
  },

  addControl : function(el) {
    this._controlsInner.prepend(el);
  },

  val : function() {
    return (this.options.choices && this.options.mode == 'prompt') ?
      this.$('input:radio:checked').val() : this.contentEl.val();
  },

  title : function(title) {
    this.$('.title').text(title);
  },

  cancel : function() {
    if (this.options.onCancel) this.options.onCancel(this);
    this.close();
  },

  info : function(message, leaveOpen) {
    this._information.removeClass('error').text(message).show();
    if (!leaveOpen) this._information.delay(3000).fadeOut();
  },

  error : function(message, leaveOpen) {
    this._information.addClass('error').text(message).show();
    if (!leaveOpen) this._information.delay(3000).fadeOut();
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
    $(this.el).align(window, '', {top : -50});
  },

  showSpinner : function() {
    this.$('.spinner_dark').show();
  },

  hideSpinner : function() {
    this.$('.spinner_dark').hide();
  },

  validateUrl : function(url) {
    if (dc.app.validator.check(url, 'url')) return true;
    this.error('Please enter a valid URL.');
    return false;
  },

  _returnCloses : function() {
    return this.options.mode == 'alert' || this.options.mode == 'short_prompt';
  },

  _maybeConfirm : function(e) {
    if (e.keyCode == 13) this.confirm();
  },

  _addFocus : function(e) {
    $(e.target).addClass('focus');
    $(this.el).css({zoom : 1});
  },

  _removeFocus : function(e) {
    $(e.target).removeClass('focus');
  }

});

_.extend(dc.ui.Dialog, {

  alert : function(text, options) {
    return new dc.ui.Dialog(_.extend({
      mode  : 'alert',
      title : null,
      text  : text
    }, options)).render();
  },

  prompt : function(text, content, callback, options) {
    var onConfirm = callback && function(dialog){ return callback(dialog.val(), dialog); };
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
      mode      : 'prompt',
      title     : text,
      choices   : choices,
      text      : '',
      onConfirm : callback && function(dialog){ return callback(dialog.val()); }
    }, options)).render();
  },

  progress : function(text, options) {
    return new dc.ui.Dialog(_.extend({
      mode  : 'progress',
      text  : text,
      title : null
    }, options)).render();
  }

});