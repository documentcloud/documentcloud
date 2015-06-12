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

  $('input[name="is_journalism"]').on('change', function(){
    if ($(this).val() == 'yes') {
      var $on  = $('#journalism_fields');
      var $off = $('#nonjournalism_fields');
    } else {
      var $on  = $('#nonjournalism_fields');
      var $off = $('#journalism_fields');
    }
    $on.removeClass('closed').addClass('open').find('input').removeAttr('tabindex');
    $off.removeClass('open').addClass('closed').find('input').attr('tabindex', '-1');;
  });

  $('input[name="approver"]').on('change', function(){
    $inputs = $('label[for="approver_other"]').find('input');
    if ($(this).val() == 'other') {
      $inputs.prop('disabled', false);
      $inputs.first().focus();
    } else {
      $inputs.prop('disabled', true);
    }
  });

  $('.form_v2 .field').on('focus', function() {
    $(this).closest('.fieldwrap').addClass('filled');
  });

  $('.form_v2 .field').on('blur', function() {
    var $elem = $(this);
    var value = $elem.val();
    if (!value || $.trim(value) == '') {
      $elem.closest('.fieldwrap').removeClass('filled valid');
    } else {
      $elem.closest('.fieldwrap').addClass('filled valid').removeClass('invalid');
    }
  });

  window.SignupPage = Backbone.View.extend({
  });

  window.signupPage = new SignupPage();

});
