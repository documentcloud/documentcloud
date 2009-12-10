dc.ui.Dialog = dc.View.extend({

  className : 'dialog',

  callbacks : [
    ['.cancel',   'click',   'close']
  ],

  constructor : function(options) {
    this.base(options);
    _.bindAll(this, 'close');
  },

  render : function() {
    $(this.el).html(JST.dialog(this.options));
    $(document.body).append(this.el);
    $(this.el).align($('#content'));
    $(this.el).draggable();
    this.setCallbacks();
    return this;
  },

  defaultOptions : function() {
    return {
      title : "Untitled Dialog",
      text  : "The content of the dialog goes here..."
    };
  },

  close : function() {
    if (this.options.onClose) this.options.onClose(this);
    $(this.el).remove();
  }

});