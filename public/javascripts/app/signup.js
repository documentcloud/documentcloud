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
    'industry':             [{
      'validators': ['isntBlank'],
      'conditions': { 'is_journalist': 'no' },
    }],
    'use_case':             [{
      'validators': ['isntBlank'],
      'conditions': { 'is_journalist': 'no' },
    }],
    'approver':             [{
      'validators': ['isTrue'],
      'conditions': { 'is_journalist': 'yes' },
    }],
    'approver_first_name':  [{
      'validators': ['isntBlank'],
      'conditions': { 'approver': 'other' },
    }],
    'approver_last_name':   [{
      'validators': ['isntBlank'],
      'conditions': { 'approver': 'other' },
    }],
    'approver_email':       [{
      'validators': ['isEmail'],
      'conditions': { 'approver': 'other' },
    }],
    'reference_links':      [{
      'validators': ['isntBlank'],
      'conditions': { 'is_journalist': 'yes' },
    }],
  },

  // Validates model attributes against validation rules. When run against 
  // entire model (default), it validates actual model attributes with `get()`. 
  // When passed a single model attribute name via `options.only`, it validates 
  // the value passed in via `attrs`, since single-attribute validation is run 
  // during `set()` before the model is actually modified. However, even 
  // single-attribute validation checks the model via `get()` for any of its 
  // conditional validations.
  validate: function(attrs, options) {
    var errors = {};

    var validations = options.only ? _.pick(this.VALIDATIONS, options.only) : this.VALIDATIONS;
    _.each(validations, function(validators, attr) {
      var value = options.only ? attrs[attr] : this.get(attr);
      validators = _.isArray(validators) ? validators : ([]).push(validators);
      _.each(validators, function(validator) {
        if (typeof validator === 'object') {
          var conditions_passed = true;
          _.each(validator.conditions, function(condition_val, condition_key) {
            if (this.get(condition_key) != condition_val) { conditions_passed = false; }
          }, this);
          if (conditions_passed) {
            var conditional_validators = _.isArray(validator['validators']) ? validator['validators'] : ([]).push(validator['validators']);
            _.each(conditional_validators, function(conditional_validator) {
              var valid = this.VALIDATORS[conditional_validator](value);
              if (valid !== true) { (errors[attr] = (errors[attr] || [])).push(valid); }
            }, this);
          }
        } else {
          var valid = this.VALIDATORS[validator](value);
          if (valid !== true) { (errors[attr] = (errors[attr] || [])).push(valid); }
        }
      }, this);
    }, this);

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
    'change input[type="radio"]':         'checkForUserInput',
    'change input[type="checkbox"]':      'checkForUserInput',
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
      // TODO: The `closest()` list is inefficient. Stop.
      this.$('[name="' + attr + '"]').closest('.fieldwrap, .checkwrap, .radioset').addClass('invalid');
    }, this);
  },
  
  toggleFieldFocus: function(event) {
    var $target = this.$(event.target);
    var value   = $target.val();
    if ($target.is(':focus') || value) {
      $target.closest('.fieldwrap').addClass('filled');
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

      // TODO: The `closest()` list is inefficient. Stop.
      var $fieldwrap = $target.closest('.fieldwrap, .checkwrap, .radioset');

      if (this.model.validationError) {
        $fieldwrap.addClass('invalid').removeClass('valid');
      } else {
        $fieldwrap.removeClass('invalid');
        if (value) {
          $fieldwrap.addClass('valid');
        } else {
          $fieldwrap.removeClass('valid');
        }
      }
    }
  },

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
    $on.removeClass('closed').addClass('open').find('input, textarea').prop('disabled', false);
    $off.removeClass('open').addClass('closed').find('input, textarea').prop('disabled', true);
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