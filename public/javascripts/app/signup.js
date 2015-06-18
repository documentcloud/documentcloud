SignupFormModel = Backbone.Model.extend({

  VALIDATORS: {
    isntBlank: function(val) {
      var valid = Backbone.$.trim(val) != '';
      return valid || "Please enter a value";
    },
    hasSelection: function(val) {
      var valid = Backbone.$.trim(val) != '';
      return valid || "Please choose an option";
    },
    isEmail: function(val) {
      var pattern = dc.app.validator.email;
      var valid = pattern.test(val);
      return valid || "Please enter a valid email";
    },
    isTrue: function(val) {
      var valid = !!val;
      return valid || "Must be selected";
    },
  },

  // TODO: Rewrite this to be properly declarative and take function conditions
  VALIDATIONS: {
    'requester_email':      ['isEmail'],
    'requester_first_name': ['isntBlank'],
    'requester_last_name':  ['isntBlank'],
    'organization_name':    ['isntBlank'],
    'country':              ['hasSelection'],
    'in_market':            ['isTrue'],
    // TODO: This doesn't actually work. It "works" if the user never clicks 
    // agree, because then the model has an undefined attr, but once clicked, 
    // `val()` provides a value whether checked or not. We'd need to look at 
    // the `checked` property. :|
    'agreed_to_terms':      ['isTrue'],
    'industry':             [{
      'validators': ['isntBlank'],
      'conditions': { 'in_market': 0 },
    }],
    'use_case':             [{
      'validators': ['isntBlank'],
      'conditions': { 'in_market': 0 },
    }],
    'approver':             [{
      'validators': ['isTrue'],
      'conditions': { 'in_market': 1 },
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
      'conditions': { 'in_market': 1 },
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
    return '/apply';
  },

  initialize: function() {
  },
});

SignupFormView = Backbone.View.extend({
  
  events: {
    'focus .field':                            'toggleFieldFocus',
    'blur .field':                             'toggleFieldFocus',
    'change .field':                           'checkForUserInput',
    'change input[type="radio"]':              'checkForUserInput',
    'change input[type="checkbox"]':           'checkForUserInput',
    'change input[name="in_market"]':          'checkIsInMarket',
    'change input[name="approver"]':           'checkIsApprover',
    'submit':                                  'submit',
  },
  
  initialize: function(options) {
    this.model = options.model;
    _.bindAll(this, 'saveSuccess', 'saveError');
  },
  
  render: function(){
    
  },
  
  submit: function(event){
    event.preventDefault();

    // When self is the approver, force all approver* fields to be requester.
    if (this.model.get('approver') == 'self') {
      this.model.set({
        approver_first_name: this.model.get('requester_first_name'),
        approver_last_name: this.model.get('requester_last_name'),
        approver_email: this.model.get('requester_email'),
        authorized_posting: true,
      });
    }

    this.disableForm();

    var saveForm = this.model.save({}, {
      success: this.saveSuccess,
      error: this.saveError,
    });

    // Validation failure, XHR never run
    if (!saveForm) {
      this.enableForm();
      this.displayValidationErrors();
      this.scrollTo(this.$('.invalid').first());
    }
  },

  saveSuccess: function(model, response) {
    this.replaceWithAlert('<b>Thanks!</b> We’ll be in touch.', { type: 'success' });
  },

  saveError: function(model, response) {
    // Validation succeeded but XHR failed
    this.enableForm();
    this.alert('<b>Clonk</b>, that didn’t work. Can you check everything and try again?', { type: 'error' });
    this.scrollTo(this.$currentAlert);
  },

  replaceWithAlert: function(message, opts) {
    var _alert = this.makeAlert(message, opts);
    this.$el.animate({
      height:  'toggle',
      opacity: 'toggle',
    }, 250, function() {
      $(this).html(_alert).animate({
        height:  'toggle',
        opacity: 'toggle',
      });
    });
  },

  makeAlert: function(message, opts) {
    if (this.$currentAlert) { this.$currentAlert.remove(); }
    this.$currentAlert = Backbone.$('<div class="alert_v2"></div>').html(message);
    if (_.has(opts, 'type')) { this.$currentAlert.addClass(opts.type); }
    return this.$currentAlert;
  },

  alert: function(message, opts) {
    opts = opts || {};

    this.makeAlert(message, opts);

    var positions = ['before', 'after', 'prepend', 'append'];
    var position  = _.find(positions, function(pos) { return _.has(opts, pos); });

    // Default to prepending within `this.$el` if nothing specified
    if (_.isUndefined(position)) {
      position = 'prepend';
      opts.prepend = true;
    }

    // If position is indicated as a boolean (`prepend: true`), it positions 
    // relative to the view's element. Otherwise, it assumes we're passing in a 
    // string selector or jQuery object (`prepend: '#alert-wrapper'`).
    if (_.isBoolean(opts[position])) {
      this.$el[position](this.$currentAlert);
    } else {
      Backbone.$(opts[position])[position](this.$currentAlert);
    }

  },

  // Saves current `disabled` property to a data attribute so the form can be
  // re-enabled to its previous state.
  disableForm: function() {
    this.$('input, textarea, select, button').each(function(){
      var $this = $(this);
      $this.data('disabled', $this.prop('disabled')).prop('disabled', true);
    });
  },

  // Restores a form to its state prior to being disabled via `disableForm()`
  enableForm: function() {
    this.$('input, textarea, select, button').each(function(){
      var $this = $(this);
      $this.prop('disabled', !!$this.data('disabled')).removeData('disabled');
    });
  },

  displayValidationErrors: function() {
    _.each(this.model.validationError, function(messages, attr) {
      var $element = this.$('[name="' + attr + '"]');

      if ($element.hasClass('field')) {
        var $fieldwrap = $element.closest('.fieldwrap').addClass('invalid').removeClass('valid');
        $fieldwrap.find('.fieldalert').remove()
        var $fieldalert = $('<ul class="fieldalert"><li>' + messages.join('</li><li>') + '</li></ul>');
        $fieldwrap.append($fieldalert);
      } else if ($element.is('[type="checkbox"]')) {
        var $fieldwrap = $element.closest('.checkwrap').addClass('invalid').removeClass('valid')
        $fieldwrap.find('.fieldalert').remove()
        var $fieldalert = $('<span class="fieldalert"> (' + messages.join(' and ') + ')</span>');
        $fieldwrap.find('> label').append($fieldalert);
      } else if ($element.is('[type="radio"]')) {
        var $fieldwrap = $element.closest('.radioset').addClass('invalid').removeClass('valid')
        $fieldwrap.find('.fieldalert').remove()
        var $fieldalert = $('<span class="fieldalert"> (' + messages.join(' and ') + ')</span>');
        $fieldwrap.find('.radioset_label').append($fieldalert);
      }
    }, this);
  },
  
  // Accepts either a string or an (assumed) jQuery object and scrolls the 
  // viewport to 50px above it (or top, if we're less than 50 from the top).
  scrollTo: function(target) {
    if (target.length < 1) { return; }
    $target = _.isString(target) ? Backbone.$(target) : target;
    var offset = $target.offset();
    var scrollToPos = (offset.top - 50) < 0 ? 0 : (offset.top - 50); 
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
        this.displayValidationErrors();
      } else {
        $fieldwrap.removeClass('invalid').find('.fieldalert').remove();
        if (value) {
          $fieldwrap.addClass('valid');
        } else {
          $fieldwrap.removeClass('valid');
        }
      }
    }
  },

  checkIsInMarket: function(event) {
    var $target = this.$(event.target);

    if ($target.val() == 1) {
      this.$('#in_market_fields').removeClass('closed').addClass('open')
          .find('input[type="radio"], textarea').prop('disabled', false);
      this.$('#non_in_market_fields').removeClass('open').addClass('closed')
          .find('.field, textarea').prop('disabled', true);
    } else {
      this.$('#in_market_fields').removeClass('open').addClass('closed')
          .find('input[type="radio"], textarea').prop('disabled', true);
      this.$('#non_in_market_fields').removeClass('closed').addClass('open')
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