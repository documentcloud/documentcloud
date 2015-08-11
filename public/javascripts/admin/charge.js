PaymentChargeFormModel = dc.ui.FormModel.extend({

  VALIDATIONS: {
    'amount':                 ['isCurrency'],
    'card_name':              ['isntBlank'],
    'card_number':            ['isInteger'],
    'card_verification_code': ['isInteger'],
    'card_expiry':            ['isMMYY'],
    'billing_postal_code':    ['isntBlank'],
  },

  initialize: function() {
    dc.ui.FormModel.prototype.initialize.call(this);
  },

  url: function() {},

});

PaymentChargeFormView = dc.ui.FormView.extend({
  
  paymentChargeFormEvents: {
    'submit': 'submit',
  },

  initialize: function(options) {
    dc.ui.FormView.prototype.initialize.call(this, options);
    this.events = _.extend({}, this.events, this.signupFormEvents);
    _.bindAll(this, 'saveSuccess', 'saveError');
  },
  
  render: function(){},
  
  submit: function(event){
    event.preventDefault();

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
    this.replaceWithAlert('<b>Success!</b> The card was successfully processed', { type: 'success' });
    this.$el.scrollTo();
  },

  saveError: function(model, response) {
    // Validation succeeded but XHR failed
    this.enableForm();
    this.alert('<b>Clonk</b>, that didn’t work. Check everything and try again?', { type: 'error' });
    this.$currentAlert.scrollTo();
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
  window.paymentChargeModel = new PaymentChargeFormModel({});
  window.paymentCharge      = new PaymentChargeFormView({ model: paymentChargeModel, el: $('#test_payment_form') });
});