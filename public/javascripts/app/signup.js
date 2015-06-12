// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

SignupFormView = Backbone.View.extend({
  
  events: {
    'focus .field':                       'enableFieldFocus',
    'change .field':                      'checkForUserInput',
    'blur .field':                        'checkForUserInput',
    'change input[name="is_journalist"]': 'checkIsJournalist',
    'change input[name="approver"]':      'checkIsApprover',
  },
  
  initialize: function(options) {
    this.model = options.model;
  },
  
  render: function(){
    
  },
  
  enableFieldFocus: function(event) {
    var $target = $(event.target);
    $target.closest('.fieldwrap').addClass('filled');
  },

  checkForUserInput: function(event) {
    var $target = $(event.target);
    var value   = $target.val();
    // TODO: Figure out why our Backbone won't allow simply `set(key, val)`
    var attrs = {};
    attrs[$target.attr('name')] = value;
    this.model.set(attrs);
    if (!value || $.trim(value) == '') {
      $target.closest('.fieldwrap').removeClass('filled');
    } else {
      $target.closest('.fieldwrap').addClass('filled');
    }
  },

  validateUserInput: function(event) {
    var $target = $(event.target);
    var value   = $target.val();
    if (value) {
      $target.closest('.fieldwrap').addClass('valid').removeClass('invalid');
    } else {
      $target.closest('.fieldwrap').addClass('invalid').removeClass('valid');
    }
  },

  checkIsJournalist: function(event) {
    var $target = $(event.target);
    var $journo_fields    = $('#journalism_fields');
    var $nonjourno_fields = $('#nonjournalism_fields');

    if ($target.val() == 'yes') {
      var $on  = $journo_fields;
      var $off = $nonjourno_fields;
    } else {
      var $on  = $nonjourno_fields;
      var $off = $journo_fields;
    }
    $on.removeClass('closed').addClass('open').find('input').removeAttr('tabindex');
    $off.removeClass('open').addClass('closed').find('input').attr('tabindex', '-1');;
  },

  checkIsApprover: function(event) {
    var $target = $(event.target);

    var $inputs = this.$el.find('label[for="approver_other"]').find('.field');
    if ($target.val() == 'other') {
      $inputs.prop('disabled', false);
      $inputs.first().focus();
    } else {
      $inputs.prop('disabled', true).trigger('blur');
    }
  },
});

$(function() {
  window.signupModel = new Backbone.Model({});
  window.signup = new SignupFormView({ model: signupModel, el: $('#new_verification_request') });
});