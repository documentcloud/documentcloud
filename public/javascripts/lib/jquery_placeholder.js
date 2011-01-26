(function($) {

  var fakeInput = document.createElement('input');
  var supportsPlaceholder = 'placeholder' in fakeInput;

  $.fn.extend({  

    placeholder: function(opts) {
      if (supportsPlaceholder) return;
      var options = $.extend({}, {className: 'placeholder'}, opts);
      var otherEl;
      
      this.each(function() {
        var el = $(this);
        var message = el.attr('placeholder');
        var placeholder = $('<div class="'+options.className+'">' + message + '</div>');
        placeholder.hide().prependTo(el[0].parentNode);
        el.bind('blur', function(){
          if (el.val() == '') placeholder.show();
        });
        el.bind('focus', function(){
          otherEl = this;
          placeholder.hide();
        });
        placeholder.bind('click', function(){
          $(otherEl).blur();
          el.focus();
        });
        el.blur();
      });
    }
    
  });
    
})(jQuery);