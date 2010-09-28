// Account Model

dc.model.Account = dc.Model.extend({

  ADMINISTRATOR   : 1,

  CONTRIBUTOR     : 2,

  ROLE_NAMES      : ['', 'administrator', 'contributor'],

  GRAVATAR_BASE   : location.protocol + (location.protocol == 'https:' ? '//secure.' : '//www.') + 'gravatar.com/avatar/',

  DEFAULT_AVATAR  : location.protocol + '//' + location.host + '/images/embed/icons/user_blue_32.png',

  BLANK_ACCOUNT   : {first_name : '', last_name : '', email : '', role : 2},

  constructor : function(attributes) {
    this.base(attributes || this.BLANK_ACCOUNT);
  },

  organization : function() {
    return Organizations.get(this.get('organization_id'));
  },

  openDocuments : function(options) {
    options || (options = {});
    var suffix = options.published ? ' access: published' : '';
    dc.app.searcher.search('account: ' + this.get('slug') + suffix);
  },

  openOrganizationDocuments : function() {
    dc.app.searcher.search('group: ' + dc.app.organization.slug);
  },

  checkAllowedToEdit: function(resource) {
    var resourceId = resource.get('document_id') || resource.id;
    if (resource.get('account_id') == this.id) return true;
    if (resource.get('organization_id') == this.get('organization_id') && this.isAdmin()) return true;
    if (Projects.isDocumentIdShared(resourceId)) return true;
  },

  fullName : function(nonbreaking) {
    var name = this.get('first_name') + ' ' + this.get('last_name');
    return nonbreaking ? name.replace(/\s/g, '&nbsp;') : name;
  },

  isAdmin : function() {
    return this.get('role') == this.ADMINISTRATOR;
  },

  gravatarUrl : function(size) {
    var hash = this.get('hashed_email');
    var fallback = encodeURIComponent(this.DEFAULT_AVATAR);
    return this.GRAVATAR_BASE + hash + '.jpg?s=' + size + '&d=' + fallback;
  }

});

// Account Set

dc.model.AccountSet = dc.Collection.extend({

  resource : 'accounts',
  model    : dc.model.Account,

  comparator : function(account) {
    return (account.get('last_name') || '').toLowerCase() + ' ' + (account.get('first_name') || '').toLowerCase();
  },

  // Fetch the account of the logged-in journalist.
  current : function() {
    return this.get(dc.app.accountId);
  },

  // Override populate to preserve the already-loaded current account.
  populate : function(options) {
    var current = this.current();
    if (!current) return this.base(options);
    var success = options.success;
    this.base(_.extend(options, { success : _.bind(function() {
      this.remove(this.get(current.id), true);
      this.add(current, true);
      if (success) success();
    }, this)}));
  },

  // If the contributor has logged-out of the workspace in a different tab,
  // force the logout here.
  forceLogout : function() {
    dc.ui.Dialog.alert('You are no longer logged in to DocumentCloud.', {onClose : function() {
      window.location = '/logout';
    }});
  }

});

window.Accounts = new dc.model.AccountSet();
