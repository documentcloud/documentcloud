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
    ['.save_changes',     'click',  'doneEditing'],
    ['.delete_account',   'click',  'deleteAccount']
  ],
  
  constructor : function(account, kind) {
    this.kind       = kind;
    this.tagName    = this.TAGS[kind];
    this.className  = 'account_view ' + this.kind;
    this.base();
    this.account    = account;
    this.template   = dc.templates['ACCOUNT_' + this.kind.toUpperCase()];
    _.bindAll('render', this);
    this.account.bind(dc.Model.CHANGED, this.render);
  },
  
  render : function(viewMode) {
    viewMode = viewMode || 'display';
    var attrs = {account : this.account, email : this.account.get('email'), size : this.AVATAR_SIZES[this.kind]};
    if (this.isRow()) this.setMode(viewMode, 'view');
    $(this.el).html(this.template(attrs));
    if (this.isRow()) this.setCallbacks();
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

  doneEditing : function() {
    var attributes = this.serialize();
    if (this.account.id < 0 && !attributes.email) return $(this.el).remove(); 
    this.account.set(attributes);
    if (this.account.id < 0) Accounts.create(this.account);
    this.setMode('display', 'view');
  },
  
  deleteAccount : function() {
    if (!confirm('Really delete ' + this.account.fullName() + '?')) return;
    $(this.el).remove();
    Accounts.destroy(this.account);
  },
  
  warnEmailTaken : function() {
    dc.app.notifier.show({
      text      : 'that email address is already taken',
      anchor    : $('td.email a')[0],
      position  : 'center right',
      left      : 20
    });
  }
  
});