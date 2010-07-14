// Account Model

dc.model.Account = dc.Model.extend({

  ADMINISTRATOR   : 1,

  CONTRIBUTOR     : 2,

  ROLE_NAMES      : ['', 'administrator', 'contributor'],

  GRAVATAR_BASE   : 'http://www.gravatar.com/avatar/',

  DEFAULT_AVATAR  : location.protocol + '//' + location.host + '/images/embed/icons/user_blue_32.png',

  BLANK_ACCOUNT   : {first_name : '', last_name : '', email : '', role : 2},

  constructor : function(attributes) {
    this.base(attributes || this.BLANK_ACCOUNT);
  },

  organization : function() {
    return Organizations.get(this.get('organization_id'));
  },

  openDocuments : function() {
    dc.app.searchBox.search('account: ' + this.get('email'));
  },

  openOrganizationDocuments : function() {
    dc.app.searchBox.search('group: ' + dc.app.organization.slug);
  },

  allowedToEdit: function(resource) {
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

dc.model.AccountSet = dc.model.RESTfulSet.extend({

  resource : 'accounts',
  model    : dc.model.Account,

  comparator : function(account) {
    return (account.get('last_name') || '').toLowerCase() + ' ' + (account.get('first_name') || '').toLowerCase();
  },

  // Fetch the account of the logged-in journalist.
  current : function() {
    return this.get(dc.app.accountId);
  }

});

dc.model.AccountSet.implement(dc.model.SortedSet);

window.Accounts = new dc.model.AccountSet();
