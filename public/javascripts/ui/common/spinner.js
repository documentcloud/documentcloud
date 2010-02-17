// There's only a single global instance of the Spinner. show() it, passing in
// a message, and hide() it when the corresponding action has finished.
dc.ui.spinner = {

  show : function(message) {
    this.ensureElement();
    message = message || "Loading";
    // this.messageContainer.html(message);
    this.el.fadeIn('fast');
  },

  hide : function() {
    this.ensureElement();
    this.el.fadeOut('fast', function(){ $(this).css({display : 'none'}); });
  },

  ensureElement : function() {
    if (this.el) return;
    $(document.body).append(JST.common_spinner({}));
    this.el = $('#spinner');
    // this.messageContainer = $('#spinner_text', this.el);
  }

};

_.bindAll(dc.ui.spinner, 'show', 'hide');