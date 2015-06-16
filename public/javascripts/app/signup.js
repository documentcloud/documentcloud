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

  // TODO: Rewrite this to be properly declarative and take function conditions
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
        if (typeof validator === 'string') {
          var valid = this.VALIDATORS[validator](value);
          if (valid !== true) { (errors[attr] = (errors[attr] || [])).push(valid); }
        } else {
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
    _.bindAll(this, 'saveSuccess', 'saveError');
  },
  
  render: function(){
    
  },
  
  submit: function(event){
    event.preventDefault();

    this.disableForm();

    var saveForm = this.model.save({}, {
      success: this.saveSuccess,
      error: this.saveError,
    });

    // Validation failure, XHR never run
    if (!saveForm) {
      this.enableForm();
      this.displayValidationErrors();
      this.scrollToFirstError();
    }
  },

  saveSuccess: function(model, response) {
    console.log('Server happy');
    // TODO: Move on to thanks page
    alert("Validation succeeded and XHR succeeded… which is weird because it's not wired up yet.");
  },

  saveError: function(model, response) {
    // Validation succeeded but XHR failed
    console.log('Server sad');
    this.enableForm();
    alert("Validation succeeded but XHR failed because it's not wired up yet.");
    // TODO: Display global error/instrux
  },

  disableForm: function() {
    this.$('input, textarea, select, button').each(function(){
      var $this = $(this);
      $this.data('disabled', $this.prop('disabled')).prop('disabled', true);
    });
  },

  enableForm: function() {
    this.$('input, textarea, select, button').each(function(){
      var $this = $(this);
      var storedDisabled = $this.data('disabled');
      if (storedDisabled) {
        $this.prop('disabled', storedDisabled).removeData('disabled');
      } else {
        $this.prop('disabled', false);
      }
    });
  },

  displayValidationErrors: function() {
    _.each(this.model.validationError, function(messages, attr) {
      // TODO: The `closest()` list is inefficient. Stop.
      this.$('[name="' + attr + '"]').closest('.fieldwrap, .checkwrap, .radioset').addClass('invalid');
    }, this);
  },
  
  scrollToFirstError: function() {
    var firstInvalidOffset = this.$('.invalid').first().offset();
    var scrollToPos = (firstInvalidOffset.top - 50) < 0 ? 0 : (firstInvalidOffset.top - 50); 
    Backbone.$('html, body').animate({ scrollTop: scrollToPos + 'px' });
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

    if ($target.val() == 'yes') {
      this.$('#journalism_fields').removeClass('closed').addClass('open')
          .find('input[type="radio"], textarea').prop('disabled', false);
      this.$('#nonjournalism_fields').removeClass('open').addClass('closed')
          .find('.field, textarea').prop('disabled', true);
    } else {
      this.$('#journalism_fields').removeClass('open').addClass('closed')
          .find('input[type="radio"], textarea').prop('disabled', true);
      this.$('#nonjournalism_fields').removeClass('closed').addClass('open')
          .find('.field, textarea').prop('disabled', false);
    }
  },

  checkIsApprover: function(event) {
    var $target = this.$(event.target);

    var $inputs = this.$('label[for="approver_other"]').find('.field');
    if ($target.val() == 'other') {
      $inputs.prop('disabled', false);
      $inputs.first().focus();
    } else {
      $inputs.prop('disabled', true).trigger('blur').closest('.fieldwrap').removeClass('valid invalid');
    }
  },
});

$(function() {
  window.signupModel = new SignupFormModel({});
  window.signup = new SignupFormView({ model: signupModel, el: $('#new_verification_request') });
});