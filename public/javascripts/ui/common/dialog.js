dc.ui.Dialog = dc.View.extend({

  className : 'dialog',

  DEFAULT_OPTIONS : {
    title   : "Untitled Dialog",
    text    : null,
    buttons : null
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

  render : function() {
    $(this.el).html(JST.dialog(this.options));
    var cel = this.contentEl = $('.content', this.el);
    this.controlsEl = $('.controls', this.el);
    if (this.options.content) cel.val(this.options.content);
    $(document.body).append(this.el);
    this.center();
    $(this.el).draggable();
    this.setCallbacks();
    if (this._returnCloses()) $(document.body).bind('keypress', this._maybeConfirm);
    if (cel[0]) _.defer(function(){ cel.focus(); });
    return this;
  },

  defaultOptions : function() {
    return _.clone(this.DEFAULT_OPTIONS);
  },

  append : function(el) {
    this.controlsEl.before(el);
  },

  appendControl : function(el) {
    this.controlsEl.append(el);
  },

  val : function() {
    return this.contentEl.val();
  },

  cancel : function() {
    if (this.options.onCancel) this.options.onCancel(this);
    this.close();
  },

  confirm : function() {
    if (this.options.onConfirm && !this.options.onConfirm(this)) return false;
    this.close();
  },

  close : function() {
    if (this.options.onClose) this.options.onClose(this);
    $(this.el).remove();
    if (this._returnCloses()) $(document.body).unbind('keypress', this._maybeConfirm);
  },

  center : function() {
    $(this.el).align($('#content')[0] || document.body, null, {top : -100});
  },

  _returnCloses : function() {
    return this.options.mode == 'alert' || this.options.mode == 'short_prompt';
  },

  _maybeConfirm : function(e) {
    if (e.keyCode == 13) this.confirm();
  }

}, {

  alert : function(text) {
    return new dc.ui.Dialog({
      mode  : 'alert',
      title : 'Alert',
      text  : text
    }).render();
  },

  prompt : function(text, content, callback, shortPrompt) {
    var onConfirm = callback && function(dialog){ return callback(dialog.val()); };
    return new dc.ui.Dialog({
      mode      : shortPrompt ? 'short_prompt' : 'prompt',
      title     : text,
      text      : '',
      content   : content,
      onConfirm : onConfirm
    }).render();
  },

  confirm : function(text, callback) {
    return new dc.ui.Dialog({
      mode      : 'confirm',
      title     : 'Confirm',
      text      : text,
      onConfirm : callback
    }).render();
  }

});