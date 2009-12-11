dc.ui.Dialog = dc.View.extend({

  className : 'dialog',

  callbacks : [
    ['.cancel',   'click',   'cancel'],
    ['.ok',       'click',   'confirm']
  ],

  constructor : function(options) {
    this.base(options);
    if (this.options.mode) this.setMode(this.options.mode, 'dialog');
    _.bindAll(this, 'close');
  },

  render : function() {
    $(this.el).html(JST.dialog(this.options));
    this.contentEl = $('.content', this.el);
    if (this.options.content) this.contentEl.text(this.options.content);
    $(document.body).append(this.el);
    $(this.el).align($('#content'), null, {top : -100});
    $(this.el).draggable();
    this.setCallbacks();
    if (this.contentEl[0]) this.contentEl.focus();
    return this;
  },

  defaultOptions : function() {
    return {
      title : "Untitled Dialog",
      text  : "The content of the dialog goes here..."
    };
  },

  val : function() {
    return this.contentEl.val();
  },

  cancel : function() {
    if (this.options.onCancel) this.options.onCancel(this);
    this.close();
  },

  confirm : function() {
    if (this.options.onConfirm) this.options.onConfirm(this);
    this.close();
  },

  close : function() {
    if (this.options.onClose) this.options.onClose(this);
    $(this.el).remove();
  }

}, {

  alert : function(text) {
    return new dc.ui.Dialog({
      mode  : 'alert',
      title : 'Error',
      text  : text
    }).render();
  },

  prompt : function(text, content, callback, shortPrompt) {
    return new dc.ui.Dialog({
      mode      : shortPrompt ? 'short_prompt' : 'prompt',
      title     : text,
      text      : '',
      content   : content,
      onConfirm : function(dialog){ return callback(dialog.val()); }
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