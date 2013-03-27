// A tile view for previewing an Account in a listing.
dc.ui.AccountView = Backbone.View.extend({

  AVATAR_SIZES : {
    badge          : 30,
    row            : 25,
    admin          : 25,
    collaborator   : 25,
    reviewer       : 25
  },

  TAGS : {
    badge          : 'div',
    row            : 'tr',
    admin          : 'tr',
    collaborator   : 'tr',
    reviewer       : 'tr'
  },

  events : {
    'click .edit_account':          'showEdit',
    'click .change_password':       'promptPasswordChange',
    'click .resend_welcome':        'resendWelcomeEmail',
    'click .admin_link':            '_openAccounts',
    'click .save_changes':          '_doneEditing',
    'click .cancel_changes':        '_cancelEditing',
    'click .disable_account':       '_disableAccount',
    'click .enable_account':        '_enableAccount',
    'click .login_as .minibutton':  '_loginAsAccount'
  },

  constructor : function(options) {
    this.modes      = {};
    this.kind       = options.kind;
    this.tagName    = this.TAGS[this.kind];
    this.className  = 'account_view ' + this.kind + (this.tagName == 'tr' ? ' not_draggable' : '');
    this.dialog     = options.dialog || dc.app.accounts;
    Backbone.View.call(this, options);
    this.template   = JST['account/' + this.kind];
    _.bindAll(this, '_onSuccess', '_onError');
    this._boundRender = _.bind(this.render, this, 'display');
    this.observe(this.model);
    this.dialog.open(); // FIXME - REMOVE BEFORE COMMITING
  },

  observe : function(model) {
    if (this.model) this.model.unbind('change', this._boundRender);
    this.model = model;
    this.model.bind('change', this._boundRender);
  },

  render : function(viewMode, options) {
    if (this.modes.view == 'edit') return;
    viewMode = viewMode || 'display';
    options  = options || {};
    var attrs = _.extend({
      account : this.model,
      email : this.model.get('email'),
      size : this.size(),
      current : Accounts.current()
    }, options);
    if (this.isRow()) this.setMode(viewMode, 'view');
    $(this.el).html(this.template(attrs));
    if (viewMode == 'edit') this.$('option.role_' + this.model.get('role')).attr({selected : 'selected'});
    if (this.model.isPending()) $(this.el).addClass('pending');
    this._loadAvatar();
    this._setPlaceholders();
    this.setMode(this.model.ROLE_NAMES[this.model.get('role')], 'role');
    return this;
  },

  size : function() {
    return this.AVATAR_SIZES[this.kind];
  },

  isRow : function() {
    return this.kind == 'row' || this.kind == 'admin' || this.kind == 'reviewer';
  },

  serialize : function() {
    var attrs = this.$('input, select').serializeJSON();
    if (attrs.role) attrs.role = parseInt(attrs.role, 10);
    return attrs;
  },

  showEdit : function() {
    this.$('option.role_' + this.model.get('role')).attr({selected : 'selected'});
    this.setMode('edit', 'view');
  },

  promptPasswordChange : function() {
    this.dialog.close();
    var dialog = dc.ui.Dialog.prompt('Enter your new password:', '', _.bind(function(password) {
      if (password.length > 0) {
        this.model.save({password : password}, {
          success : _.bind(function() {
            dc.ui.notifier.show({
              text      : 'Password updated',
              duration  : 5000,
              mode      : 'info'
            });
          }, this)
        });
        return true;
      } else {
        dc.ui.Dialog.alert("Your password can't be blank");
      }
    }, this), {password : true, mode : 'short_prompt'});
  },

  resendWelcomeEmail : function() {
    dc.ui.spinner.show();
    var model = this.model;
    model.resendWelcomeEmail({success : _.bind(function() {
      dc.ui.spinner.hide();
      dc.ui.notifier.show({mode : 'info', text : 'A welcome message has been sent to ' + model.get('email') + '.'});
    }, this)});
  },

  _setPlaceholders : function() {
    this.$('input[name=first_name], input[name=last_name], input[name=email]').placeholder();
  },

  _loadAvatar : function() {
    var img = new Image();
    var src = this.model.gravatarUrl(this.size());
    img.onload = _.bind(function() { this.$('img.avatar').attr({src : src}); }, this);
    img.src = src;
  },

  _openAccounts : function(e) {
    e.preventDefault();
    this.dialog.open();
  },

  // When we're done editing an account, it's either a create or update.
  // This method specializes to try and avoid server requests when nothing has
  // changed.
  _doneEditing : function() {
    var me = this;
    var attributes = this.serialize();
    var options = {success : this._onSuccess, error : this._onError};
    if (this.model.isNew()) {
      if (!attributes.email) return $(this.el).remove();
      if (Accounts.getValidByEmail(attributes.email)) { 
        this.dialog.error(""+attributes.email+" already has an account");
        return; 
      }
      dc.ui.spinner.show();
      this.model.newRecord = true;
      this.model.set(attributes);
      Accounts.create(this.model, options);
    } else if (!this.model.invalid && !this.model.changedAttributes(attributes)) {
      this.setMode('display', 'view');
    } else {
      dc.ui.spinner.show();
      this.model.save(attributes, options);
    }
  },

  _cancelEditing : function() {
    this.setMode('display', 'view');
  },

  _disableAccount : function() {
    if (this.dialog.isOpen()) this.dialog.close();
    var dialog = dc.ui.Dialog.confirm(null, _.bind(function() {
      this.setMode('display', 'view');
      this.model.save({'role': this.model.DISABLED});
      dc.ui.notifier.show({
        text      : this.model.fullName() + ' has been disabled.',
        duration  : 5000,
        mode      : 'info'
      });
      return true;
    }, this), {
      id          : 'disable_account_confirm',
      title       : 'Really disable ' + this.model.fullName() + '\'s account?',
      description : this.model.fullName() + ' will not be able to log in to DocumentCloud. Public documents and annotations provided by ' + this.model.fullName()+ ' will remain available. <span class="contact_support text_link">Contact support</span> to completely purge '+this.model.fullName()+'\'s account.',
      saveText    : 'Disable'
    });
    $('.contact_support', dialog.el).bind('click', function() {
      dialog.close();
      dc.ui.Dialog.contact();
    });
  },

  _enableAccount : function() {
    this.setMode('display', 'view');
    this.model.save({'role': this.model.CONTRIBUTOR});
  },

  _loginAsAccount : function() {
    window.location = "/admin/login_as?email=" + encodeURIComponent(this.model.get('email'));
  },

  _onSuccess : function(model, resp) {
    this.model.invalid = false;
    this.setMode('display', 'view');
    this.model.trigger('change');
    dc.ui.spinner.hide();
    if (this.model.newRecord) {
      this.model.newRecord = false;
      dc.ui.notifier.show({
        text      : 'Signup sent to ' + model.get('email'),
        duration  : 5000,
        mode      : 'info'
      });
    }
  },

  _onError : function(model, resp) {
    resp = JSON.parse(resp.responseText);
    model.invalid = true;
    dc.ui.spinner.hide();
    this.showEdit();
    this.dialog.error(resp.errors && resp.errors[0] || 'Could not add the account.');
  }

});
