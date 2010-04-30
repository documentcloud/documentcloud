// A tile view for previewing a Document in a listing.
dc.ui.AccountView = dc.View.extend({

  AVATAR_SIZES : {
    badge : 30,
    row   : 25,
    admin : 25
  },

  TAGS : {
    badge : 'div',
    row   : 'tr',
    admin : 'tr'
  },

  callbacks : {
    '.edit_account.click':    'showEdit',
    '.change_password.click': 'promptPasswordChange',
    '.admin_link.click':      '_openAccounts',
    '.save_changes.click':    '_doneEditing',
    '.delete_account.click':  '_deleteAccount'
  },

  constructor : function(options) {
    this.kind       = options.kind;
    this.tagName    = this.TAGS[this.kind];
    var grad = this.kind == 'badge' ? '' : 'gradient_white';
    this.className  = 'account_view ' + grad + ' ' + this.kind;
    this.base(options);
    this.template   = JST['account_' + this.kind];
    _.bindAll(this, '_onSuccess', '_onError');
    this.model.bind(dc.Model.CHANGED, _.bind(this.render, this, 'display'));
  },

  render : function(viewMode) {
    if (this.modes.view == 'edit') return;
    viewMode = viewMode || 'display';
    var attrs = {account : this.model, email : this.model.get('email'), size : this.size(), current : Accounts.current()};
    if (this.isRow()) this.setMode(viewMode, 'view');
    $(this.el).html(this.template(attrs));
    if (this.model.get('pending')) $(this.el).addClass('pending');
    this._loadAvatar();
    this.setCallbacks();
    return this;
  },

  size : function() {
    return this.AVATAR_SIZES[this.kind];
  },

  isRow : function() {
    return this.kind == 'row' || this.kind == 'admin';
  },

  serialize : function() {
    var attrs = $('input, select', this.el).serializeJSON();
    if (attrs.role) attrs.role = parseInt(attrs.role, 10);
    return attrs;
  },

  showEdit : function() {
    $('option.role_' + this.model.get('role'), this.el).attr({selected : 'selected'});
    this.setMode('edit', 'view');
  },

  promptPasswordChange : function() {
    var dialog = dc.ui.Dialog.prompt('Enter your new password:', '', _.bind(function(password) {
      Accounts.update(this.model, {password : password}, {success : _.bind(function() {
        dc.ui.notifier.show({
          text      : 'Password updated',
          duration  : 5000,
          mode      : 'info'
        });
      }, this)});
      return true;
    }, this), 'password');
  },

  _loadAvatar : function() {
    var img = new Image();
    var src = this.model.gravatarUrl(this.size());
    img.onload = _.bind(function() { $('img.avatar', this.el).attr({src : src}); }, this);
    img.src = src;
  },

  _openAccounts : function(e) {
    e.preventDefault();
    dc.app.accounts.open();
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
      dc.ui.spinner.show('saving');
      Accounts.create(this.model, attributes, options);
    } else if (!this.model.invalid && !this.model.changedAttributes(attributes)) {
      this.setMode('display', 'view');
    } else {
      dc.ui.spinner.show('saving');
      Accounts.update(this.model, attributes, options);
    }
  },

  _deleteAccount : function() {
    dc.ui.Dialog.confirm('Really delete ' + this.model.fullName() + '?', _.bind(function() {
      $(this.el).remove();
      Accounts.destroy(this.model);
      return true;
    }, this));
  },

  _onSuccess : function(model, resp) {
    var newAccount = model.isNew();
    model.invalid = false;
    dc.ui.spinner.hide();
    this.setMode('display', 'view');
    model.set(resp);
    model.changed();
    if (newAccount) dc.ui.notifier.show({
      text      : 'Signup sent to ' + model.get('email'),
      duration  : 5000,
      mode      : 'info'
    });
  },

  _onError : function(model, resp) {
    model.invalid = true;
    dc.ui.spinner.hide();
    this.showEdit();
    dc.ui.notifier.show({
      text : resp.errors[0]
    });
  }

});