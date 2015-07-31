dc.ui.FormModel = Backbone.Model.extend({

  VALIDATORS: {
    isntBlank: function(val) {
      var valid = Backbone.$.trim(val) != '';
      return valid || "We need this info.";
    },
    isEmail: function(val) {
      var pattern = dc.app.validator.email;
      var valid   = pattern.test(val);
      return valid || "We need a valid email.";
    },
    isInteger: function(val) {
      var pattern = /^[0-9]+$/;
      var valid   = pattern.test(val);
      return valid || "Enter numbers only.";
    },
    isCurrency: function(val) {
      var pattern = /^[0-9]+(\.[0-9]{1,2})?$/;
      var valid   = pattern.test(val);
      return valid || "Enter a valid dollar amount.";
    },
    isMMYY: function(val) {
      var pattern = /^[0-9]{2}\/[0-9]{2}$/;
      var valid   = pattern.test(val);
      return valid || "Enter date as MM/YY.";
    },
    isChosen: function(val) {
      var valid = !!val;
      return valid || "Please choose one.";
    },
    // For this to actually work, you have to manually be providing the model 
    // attribute with `$field.prop('checked')` instead of `$field.val()` before 
    // running the validation.
    isChecked: function(val) {
      var valid = !!val;
      return valid || "We require this.";
    },
  },

  // Set these on each child instance, in the form of:
  //  'first_name':      ['isntBlank'],
  //  'email':           ['isEmail'],
  //  'agreed_to_terms': ['isChecked'],
  //  'spouse_name':     [{
  //     'validators': ['isntBlank'],
  //     'conditions': { 'married': 1 },
  //  }],
  // TODO: Rewrite these to be properly declarative and take function conditions
  VALIDATIONS: {},

  initialize: function() {},

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

});

dc.ui.FormView = Backbone.View.extend({

  events: {
    'focus  .field':                 'toggleFocusFilledState',
    'blur   .field':                 'toggleFocusFilledState',
    'change .field':                 'checkForUserInput',
    'change input[type="radio"]':    'checkForUserInput',
    'change input[type="checkbox"]': 'checkForUserInput',
  },

  initialize: function(options) {
    this.model = options.model || new dc.ui.FormModel({});
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
        var $fieldalert = $('<span class="fieldalert">' + messages.join(' ') + '</span>');
        $fieldwrap.find('> label').append($fieldalert);
      } else if ($element.is('[type="radio"]')) {
        var $fieldwrap = $element.closest('.radioset').addClass('invalid').removeClass('valid')
        $fieldwrap.find('.fieldalert').remove()
        var $fieldalert = $('<span class="fieldalert">' + messages.join(' ') + '</span>');
        $fieldwrap.find('.radioset_label').append($fieldalert);
      }
    }, this);
  },
  
  // Our labels are positioned within form fields, ala placeholders. When it 
  // has focus or has a value, we give its parent wrapper a `filled` class, 
  // which positions the label appropriately.
  toggleFocusFilledState: function(event) {
    var $target = this.$(event.target);
    var value   = $target.val();
    if ($target.is(':focus') || value) {
      $target.closest('.fieldwrap').addClass('filled');
    } else {
      $target.closest('.fieldwrap').removeClass('filled');
    }
  },

  // Bound to form fields and called on change, this keeps model attributes in 
  // sync with the latest form data, displays model validation errors, and 
  // clears old validation errors.
  checkForUserInput: function(event) {
    var $target = this.$(event.target);
    var attr    = $target.attr('name');
    var value   = $target.is('[type="checkbox"]') ? $target.prop('checked') : $target.val();

    this.toggleFocusFilledState(event);

    // Don't set the model if we're just tabbing through
    if (value || this.model.get(attr)) {
      var attrs   = {};
      attrs[attr] = value;
      // We set this despite validation because we want the model in sync with
      // what the user is seeing.
      this.model.set(attrs);
      this.model._validate(attrs, { validate: true, only: attr });

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

  // `.val()` on checkboxes returns `on` instead of useful information about 
  // checked state. Fill model with boolean based on `.prop('checked')` instead.
  // On view instead of model because we have to interact with the DOM.
  setCheckboxValues: function() {
    var checkboxes = {};
    this.$('[type="checkbox"]').each(function(i, checkbox) {
      var $checkbox = $(checkbox);
      checkboxes[$checkbox.attr('name')] = $checkbox.prop('checked');
    });
    this.model.set(checkboxes);
  },

});