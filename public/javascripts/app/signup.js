SignupFormModel = dc.ui.FormModel.extend({

  VALIDATIONS: {
    'requester_email':      ['isEmail'],
    'requester_first_name': ['isntBlank'],
    'requester_last_name':  ['isntBlank'],
    'organization_name':    ['isntBlank'],
    'country':              ['isChosen'],
    'in_market':            ['isChosen'],
    'agreed_to_terms':      ['isChecked'],
    'industry':             [{
      'validators': ['isntBlank'],
      'conditions': { 'in_market': 0 },
    }],
    'use_case':             [{
      'validators': ['isntBlank'],
      'conditions': { 'in_market': 0 },
    }],
    'approver':             [{
      'validators': ['isChosen'],
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
    'requester_position':   [{
      'validators': ['isntBlank'],
      'conditions': { 'approver': 'self' },
    }],
    'reference_links':      [{
      'validators': ['isntBlank'],
      'conditions': { 'in_market': 1 },
    }],
  },

  initialize: function() {
    dc.ui.FormModel.prototype.initialize.call(this);
  },

  url: function() {
    return '/apply';
  },

  maybeSelfApprove: function() {
    if (this.get('approver') == 'self') {
      this.set({
        approver_first_name: this.get('requester_first_name'),
        approver_last_name:  this.get('requester_last_name'),
        approver_email:      this.get('requester_email'),
        authorized_posting:  true,
      });
    }
  },

});

SignupFormView = dc.ui.FormView.extend({
  
  signupFormEvents: {
    'change input[name="in_market"]': 'checkIsInMarket',
    'change input[name="approver"]':  'checkIsApprover',
    'submit':                         'submit',
  },

  initialize: function(options) {
    dc.ui.FormView.prototype.initialize.call(this, options);
    this.events = _.extend({}, this.events, this.signupFormEvents);
    _.bindAll(this, 'saveSuccess', 'saveError');
  },
  
  render: function(){},
  
  submit: function(event){
    event.preventDefault();

    this.setCheckboxValues();
    this.model.maybeSelfApprove();

    this.disableForm();
    var saveForm = this.model.save({}, {
      success: this.saveSuccess,
      error:   this.saveError,
    });

    // Validation failure, XHR never run
    if (!saveForm) {
      this.enableForm();
      this.displayValidationErrors();
      this.$('.invalid').scrollTo();
    }
  },

  saveSuccess: function(model, response) {
    this.replaceWithAlert('<b>Thanks!</b> We’ll be in touch.', { type: 'success' });
    this.$el.scrollTo();
  },

  saveError: function(model, response) {
    // Validation succeeded but XHR failed
    this.enableForm();
    this.alert('<b>Clonk</b>, that didn’t work. Check everything and try again?', { type: 'error' });
    this.$currentAlert.scrollTo();
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

    var $other_inputs = this.$('label[for="approver_other"]').find('.field');
    var $self_inputs  = this.$('label[for="approver_self"]').find('.field');
    if ($target.val() == 'other') {
      $other_inputs.prop('disabled', false);
      $other_inputs.first().focus();
      $self_inputs.prop('disabled', true).trigger('blur')
                  .closest('.fieldwrap').removeClass('valid invalid');
    } else {
      $self_inputs.prop('disabled', false);
      $self_inputs.first().focus();
      $other_inputs.prop('disabled', true).trigger('blur')
                   .closest('.fieldwrap').removeClass('valid invalid');
    }
  },

  // TODO: Extract to alert library

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
      position     = 'prepend';
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

});

$(function() {
  window.signupModel = new SignupFormModel({});
  window.signup      = new SignupFormView({ model: signupModel, el: $('#new_verification_request') });
});