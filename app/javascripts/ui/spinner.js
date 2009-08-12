dc.ui.Spinner = {
  
  show : function(message) {
    message = message || "Loading";
    if (!this.el) {
      $(document.body).append(dc.templates.COMMON_SPINNER({}));
      this.el = $('#spinner');
      this.messageContainer = $('#spinner_text', this.el);
    }
    this.messageContainer.html(message);
    this.el.fadeIn('fast');
  },
  
  hide : function() {
    this.el.fadeOut('fast', function(){ $(this).css({display : 'none'}); });
  }
  
};