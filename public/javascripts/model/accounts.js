// Account Model

dc.model.Account = Backbone.Model.extend({

  ADMINISTRATOR   : 1,

  CONTRIBUTOR     : 2,

  REVIEWER        : 3,

  ROLE_NAMES      : ['', 'administrator', 'contributor', 'reviewer'],

  GRAVATAR_BASE   : location.protocol + (location.protocol == 'https:' ? '//secure.' : '//www.') + 'gravatar.com/avatar/',

  DEFAULT_AVATAR  : location.protocol + '//' + location.host + '/images/embed/icons/user_blue_32.png',

  BLANK_ACCOUNT   : {first_name : '', last_name : '', email : '', role : 2},

  constructor : function(attributes) {
    if (attributes) attributes = _.extend(this.BLANK_ACCOUNT, attributes);
    Backbone.Model.call(this, attributes || this.BLANK_ACCOUNT);
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
    dc.app.searcher.search('group: ' + dc.account.organization.slug);
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

  documentsTitle : function() {
    return Inflector.possessivize(this.fullName()) + ' Documents';
  },

  isAdmin : function() {
    return this.get('role') == this.ADMINISTRATOR;
  },

  isPending : function() {
    return !!this.get('pending');
  },

  searchUrl : function() {
    return "/#search/" + encodeURIComponent("account: " + this.get('slug'));
  },

  gravatarUrl : function(size) {
    var hash = this.get('hashed_email');
    var fallback = encodeURIComponent(this.DEFAULT_AVATAR);
    return this.GRAVATAR_BASE + hash + '.jpg?s=' + size + '&d=' + fallback;
  },

  resendWelcomeEmail: function(options) {
    var url = '/accounts/' + this.id + '/resend_welcome';
    $.ajax(_.extend(options || {}, {type : 'POST', dataType : 'json', url : url}));
  }

});

// Account Set

dc.model.AccountSet = Backbone.Collection.extend({

  model : dc.model.Account,
  url   : '/accounts',

  comparator : function(account) {
    return (account.get('last_name') || '').toLowerCase() + ' ' + (account.get('first_name') || '').toLowerCase();
  },

  getBySlug : function(slug) {
    return this.detect(function(account) {
      return account.get('slug') === slug;
    });
  },

  // Fetch the account of the logged-in journalist.
  current : function() {
    if (!dc.account) return null;
    return this.get(dc.account.id);
  },

  // All accounts other than yours.
  others : function() {
    return this.filter(function(account) {
      return account.id !== dc.account.id;
    });
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
