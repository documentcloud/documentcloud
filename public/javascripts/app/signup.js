// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

SignupFormModel = Backbone.Model.extend({

  VALIDATORS: {
    isntBlank: function(val) {
      var valid = Backbone.$.trim(val) != '';
      return valid || "Please enter a value.";
    },
    isEmail: function(val) {
      var pattern = dc.app.validator.email;
      var valid = pattern.test(val);
      return valid || "Please enter a valid email.";
    },
    isTrue: function(val) {
      var valid = !!val;
      return valid || "Must be selected.";
    },
  },

  VALIDATIONS: {
    'requester_email':      ['isEmail'],
    'requester_first_name': ['isntBlank'],
    'requester_last_name':  ['isntBlank'],
    'organization_name':    ['isntBlank'],
    'country':              ['isntBlank'],
    'is_journalist':        ['isTrue'],
    'agreed_to_terms':      ['isTrue'],
  },

  validateField: function(model, fieldName, value){
    
  },

  validate: function(attrs, options) {
    var errors = {};

    if (options.only) {
      var attr = options.only;
      _.each(this.VALIDATIONS[attr], function(validator) {
        var valid = this.VALIDATORS[validator](attrs[attr]);
        if (valid !== true) { (errors[attr] = (errors[attr] || [])).push(valid); }
      }, this);
    } else {
      _.each(this.VALIDATIONS, function(validators, attr) {
        _.each(validators, function(validator) {
          var valid = this.VALIDATORS[validator](this.get(attr));
          if (valid !== true) { (errors[attr] = (errors[attr] || [])).push(valid); }
        }, this);
      }, this);
    }

    if (!_.isEmpty(errors)) {
      return errors;
    }
  },

  url: function() {
    return '/signup';
  },

  initialize: function() {
  },
});

SignupFormView = Backbone.View.extend({
  
  events: {
    'focus .field':                       'toggleFieldFocus',
    'blur .field':                        'toggleFieldFocus',
    'change .field':                      'checkForUserInput',
    'change input[name="is_journalist"]': 'checkIsJournalist',
    'change input[name="approver"]':      'checkIsApprover',
    'submit':                             'submit',
  },
  
  initialize: function(options) {
    this.model = options.model;
  },
  
  render: function(){
    
  },
  
  submit: function(event){
    event.preventDefault();

    // TODO: Disable form before XHR

    var saveForm = this.model.save({}, {
      success: function() {
        // Validation succeeded and XHR worked
        // TODO: Move on to thanks page
        console.log('Server happy');
      },
      error: function() {
        // Validation succeeded but XHR failed
        // TODO: Display global error/instrux
        console.log('Server sad');
      },
    });

    // TODO: Re-enable form after XHR

    if (!saveForm) {
      // Validation failure, XHR (was) halted
      console.log(this.model.validationError);
      this.displayValidationErrors();
    }
  },

  displayValidationErrors: function() {
    _.each(this.model.validationError, function(messages, attr) {
      this.$('[name="' + attr + '"]').closest('.fieldwrap, .checkwrap, .radioset').addClass('invalid');
    }, this);
  },
  
  toggleFieldFocus: function(event) {
    var $target = this.$(event.target);
    var value   = $target.val();
    if ($target.is(':focus') || value) {
      $target.closest('.w').addClass('filled');
    } else {
      $target.closest('.fieldwrap').removeClass('filled');
    }
  },

  checkForUserInput: function(event) {
    var $target = this.$(event.target);
    var attr    = $target.attr('name');
    var value   = $target.val();

    this.toggleFieldFocus(event);

    // Don't set the model if we're just tabbing through
    if (value || this.model.get(attr)) {
      // TODO: Figure out why our Backbone won't allow simply `set(key, val)`
      var attrs = {};
      attrs[$target.attr('name')] = value;
      this.model.set(attrs, { validate: true, only: attr });

      var $fieldwrap = $target.closest('.fieldwrap, .checkwrap, .radioset');
      if (this.model.validationError) {
        $fieldwrap.addClass('invalid').removeClass('valid');
      } else {
        $fieldwrap.addClass('valid').removeClass('invalid');
      }
    }
  },

  // validateUserInput: function(event) {
  //   var $target = this.$(event.target);
  //   var value   = $target.val();
  //   if (value) {
  //     $target.closest('.fieldwrap').addClass('valid').removeClass('invalid');
  //   } else {
  //     $target.closest('.fieldwrap').addClass('invalid').removeClass('valid');
  //   }
  // },

  checkIsJournalist: function(event) {
    var $target = this.$(event.target);
    var $journo_fields    = this.$('#journalism_fields');
    var $nonjourno_fields = this.$('#nonjournalism_fields');

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
    var $target = this.$(event.target);

    var $inputs = this.$('label[for="approver_other"]').find('.field');
    if ($target.val() == 'other') {
      $inputs.prop('disabled', false);
      $inputs.first().focus();
    } else {
      $inputs.prop('disabled', true).trigger('blur');
    }
  },
});

$(function() {
  window.signupModel = new SignupFormModel({});
  window.signup = new SignupFormView({ model: signupModel, el: $('#new_verification_request') });
});