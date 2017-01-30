// Account Model

dc.model.Account = Backbone.Model.extend({

  // TODO: Remove once JSTs aren't reliant [JR]
  ROLE_NAMES         : ['disabled', 'administrator', 'contributor', 'reviewer', 'freelancer'],

  GRAVATAR_BASE      : location.protocol + (location.protocol == 'https:' ? '//secure.' : '//www.') + 'gravatar.com/avatar/',

  DEFAULT_AVATAR     : location.protocol + '//' + location.host + '/images/embed/icons/user_blue_32.png',

  defaults           : { first_name : '', last_name : '', email : '', role : 2 },
  
  initialize: function(options) {
    this.memberships = new dc.model.MembershipSet();
    if (this.get('memberships')) { this.memberships.reset(this.get('memberships')); }
  },

  // TODO: Remove this shim, which is basically only here for the current AccountView that's going away with Circlet [JR]
  role: function() {
    return this.get('role');
  },

  isMemberOf: function(organizationId) {
    return !!this.memberships.findWhere({organization_id: parseInt(organizationId, 10)});
  },

  currentMembership: function() {
    this._currentMembership = this._currentMembership || this.memberships.current();
    return this._currentMembership;
  },

  currentOrganization: function() {
    this._currentOrganization = this._currentOrganization || Organizations.get(this.currentMembership().get('organization_id'));
    return this._currentOrganization;
  },

  // changeCurrentOrganization: function(organizationId) {
  //   if (this.isMemberOf(organizationId)) {
  //     this.memberships.findWhere({organization_id: organizationId}).setCurrent();
  //   }
  // },

  organization: function() {
    return this.currentOrganization();
  },
  
  organization_ids: function() {
    return this.memberships.pluck('organization_id');
  },
  
  organizations: function() {
    var ids = this.organization_ids();
    return new dc.model.OrganizationSet(Organizations.filter(function(org){ return _.contains(ids, org.get('id'));}));
  },

  openDocuments : function(options) {
    options = (options || {});
    var suffix = options.published ? ' ' + _.t('filter') +':' + ' ' + _.t('published') : '';
    dc.app.searcher.search(_.t('account') + ':' + this.get('slug') + suffix);
  },

  openOrganizationDocuments : function() {
    dc.app.searcher.search( _.t('group') + ': ' + dc.account.currentOrganization().get('slug'));
  },

  allowedToEdit: function(model) {
    return this.ownsOrOrganization(model) || this.collaborates(model);
  },

  ownsOrOrganization: function(model) {
    return (model.get('account_id') == this.id) ||
           (this.isMemberOf(model.get('organization_id')) &&
            (this.isAdmin() || this.isContributor()) &&
            _.contains([
              dc.access.PUBLIC, dc.access.EXCLUSIVE, dc.access.ORGANIZATION,
              'public', 'exclusive', 'organization'
            ], model.get('access')));
  },

  collaborates: function(model) {
    var docId      = model.get('document_id') || model.id;
    var projectIds = model.get('project_ids');

    for (var i = 0, l = Projects.length; i < l; i++) {
      var project = Projects.models[i];
      if (_.contains(projectIds, project.get('id')) && !project.get('hidden')) {
        for (var j = 0, k = project.collaborators.length; j < k; j++) {
          var collab = project.collaborators.models[j];
          if (collab.ownsOrOrganization(model)) return true;
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
    return dc.inflector.possessivize(this.fullName()) + ' ' + _.t('documents');
  },

  isAdmin : function() {
    return this.currentMembership().isAdmin();
  },

  isContributor : function() {
    return this.currentMembership().isContributor();
  },

  isReviewer : function() {
    return this.currentMembership().isReviewer();
  },

  isReal : function() {
    return this.currentMembership().isReal();
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
  
  getByEmail: function(email) {
    return this.detect(function(account){
      return account.get('email') === email;
    });
  },
  
  getValidByEmail: function(email) {
    return this.detect(function(account){
      return !account.invalid && account.get('email') === email;
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
  forceLogout : function(messageStr) {
    var message = (messageStr || 'You are no longer logged in to DocumentCloud.');
    dc.ui.Dialog.alert(message, {onClose : function() {
      window.location = '/logout';
    }});
  }

});

window.Accounts = new dc.model.AccountSet();
