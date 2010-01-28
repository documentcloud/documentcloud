// A tile view for previewing a Document in a listing.
dc.ui.AccountView = dc.View.extend({

  AVATAR_SIZES : {
    badge : 20,
    row   : 32
  },

  TAGS : {
    badge : 'div',
    row   : 'tr'
  },

  callbacks : [
    ['.edit_account',     'click',  'showEdit'],
    ['.admin_link',       'click',  '_openAccounts'],
    ['.save_changes',     'click',  '_doneEditing'],
    ['.delete_account',   'click',  '_deleteAccount']
  ],

  constructor : function(account, kind) {
    this.kind       = kind;
    this.tagName    = this.TAGS[kind];
    this.className  = 'account_view ' + this.kind;
    this.base();
    this.account    = account;
    this.template   = JST['account_' + this.kind];
    _.bindAll(this, '_onSuccess', '_onError');
    this.account.bind(dc.Model.CHANGED, _.bind(this.render, this, 'display'));
  },

  render : function(viewMode) {
    if (this.modes.view == 'edit') return;
    viewMode = viewMode || 'display';
    var attrs = {account : this.account, email : this.account.get('email'), size : this.AVATAR_SIZES[this.kind]};
    if (this.isRow()) this.setMode(viewMode, 'view');
    $(this.el).html(this.template(attrs));
    if (this.account.get('pending')) $(this.el).addClass('pending');
    this.setCallbacks();
    return this;
  },

  isRow : function() {
    return this.kind == 'row';
  },

  serialize : function() {
    return $('input', this.el).serializeJSON();
  },

  showEdit : function() {
    this.setMode('edit', 'view');
  },

  _openAccounts : function(e) {
    e.preventDefault();
    dc.app.navigation.tab('admin');
  },

  // When we're done editing an account, it's either a create or update.
  // This method specializes to try and avoid server requests when nothing has
  // changed.
  _doneEditing : function() {
    var me = this;
    var attributes = this.serialize();
    var options = {success : this._onSuccess, error : this._onError};
    if (this.account.isNew()) {
      if (!attributes.email) return $(this.el).remove();
      dc.ui.spinner.show('creating account');
      Accounts.create(this.account, attributes, options);
    } else if (!this.account.invalid && !this.account.changedAttributes(attributes)) {
      this.setMode('display', 'view');
    } else {
      dc.ui.spinner.show('saving account');
      Accounts.update(this.account, attributes, options);
    }
  },

  _deleteAccount : function() {
    dc.ui.Dialog.confirm('Really delete ' + this.account.fullName() + '?', _.bind(function() {
      $(this.el).remove();
      Accounts.destroy(this.account);
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
      text      : 'login email sent to ' + model.get('email'),
      duration  : 5000,
      mode      : 'info',
      anchor    : $('td.last', this.el),
      position  : '-left'
    });
  },

  _onError : function(model, resp) {
    model.invalid = true;
    dc.ui.spinner.hide();
    this.showEdit();
    dc.ui.notifier.show({
      text      : resp.errors[0],
      anchor    : $('button', this.el),
      position  : 'right',
      left      : 18,
      top       : 2
    });
  }

});