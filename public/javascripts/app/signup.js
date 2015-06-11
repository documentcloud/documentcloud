// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

$(function() {

  // This is a terrible function that only exists because there's no good way
  // of observing browser autofill.
  setInterval(function() {
    $('.form_v2 .field:not(:focus)').each(function() {
      var $elem = $(this);
      var value = $elem.val();
      if (value && value != '') {
        $elem.trigger('blur')
      };
    })
  }, 250);

  $('.form_v2 .field').on('focus', function() {
    $(this).closest('.fieldwrap').addClass('filled');
  });

  $('.form_v2 .field_inline').on('focus', function() {
    $(this).addClass('filled');
  });

  $('.form_v2 .field').on('blur', function() {
    var $elem = $(this);
    var value = $elem.val();
    if (!value || $.trim(value) == '') {
      $elem.closest('.fieldwrap').removeClass('filled valid');
    } else {
      $elem.closest('.fieldwrap').addClass('filled valid');
    }
  });

  window.SignupPage = Backbone.View.extend({
  });

  window.signupPage = new SignupPage();

});
