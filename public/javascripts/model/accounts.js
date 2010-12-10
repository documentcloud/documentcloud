// Account Model

dc.model.Account = Backbone.Model.extend({

  ADMINISTRATOR      : 1,

  CONTRIBUTOR        : 2,

  REVIEWER           : 3,

  ROLE_NAMES         : ['', 'administrator', 'contributor', 'reviewer'],
  
  GRAVATAR_BASE      : location.protocol + (location.protocol == 'https:' ? '//secure.' : '//www.') + 'gravatar.com/avatar/',

  DEFAULT_AVATAR     : location.protocol + '//' + location.host + '/images/embed/icons/user_blue_32.png',

  BLANK_ACCOUNT      : {first_name : '', last_name : '', email : '', role : 2},

  constructor : function(attributes, options) {
    Backbone.Model.call(this, attributes || this.BLANK_ACCOUNT, options);
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

  allowedToEdit: function(model) {
    return this.ownsOrCollaborates(model) || this.shares(model);
  },

  ownsOrCollaborates: function(model) {
    return (model.get('account_id') == this.id) ||
           (model.get('organization_id') == this.get('organization_id') && this.isEditor());
  },

  shares: function(model) {
    var docId = model.get('document_id') || model.id;
    for (var i = 0, l = Projects.length; i < l; i++) {
      var project = Projects.models[i];
      if (_.include(project.get('document_ids'), docId)) {
        for (var j = 0, k = project.collaborators.length; j < k; j++) {
          var collab = project.collaborators.models[j];
          if (collab.ownsOrCollaborates(model)) return true;
        }
      }
    }
    return false;
  },

  fullName : function(nonbreaking) {
    var name = this.get('first_name') + ' ' + this.get('last_name');
    return nonbreaking ? name.replace(/\s/g, '&nbsp;') : name;
  },

  documentsTitle : function() {
    return Inflector.possessivize(this.fullName()) + ' Documents';
  },

  isAdmin : function() {
    return this.attributes.role == this.ADMINISTRATOR;
  },

  isEditor : function() {
    var role = this.attributes.role;
    return role == this.ADMINISTRATOR || role == this.CONTRIBUTOR;
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

dc.model.Account.COLLABORATOR_ROLES = [
  dc.model.Account.prototype.ADMINISTRATOR, 
  dc.model.Account.prototype.CONTRIBUTOR
];

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
