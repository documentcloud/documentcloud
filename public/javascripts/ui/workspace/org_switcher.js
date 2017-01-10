dc.ui.OrgSwitcher = Backbone.View.extend({

  events : {
    'click .org-switcher-link' : 'switchTo'
  },
  
  initialize: function(options) {
    // Cache element references
    this.$toggle            = this.$el.find('.org-switcher-toggle');
    this.$organizationLinks = this.$el.find('.org-switcher-link');
    this.$manage            = this.$el.find('.org-manage-link');
    this.$settings          = this.$el.find('#org-switcher-settings');

    // In case of backend/front-end sync problem
    this._markActiveOrganization();
  },

  switchTo: function(e) {
    e.preventDefault();

    var organizationId = $(e.target).data('organization-id');
    dc.account.changeCurrentOrganization(organizationId);

    this._markActiveOrganization();
    dc.account.organization().openDocuments();
  },

  _markActiveOrganization: function() {
    var organization = dc.account.organization();

    this.$toggle.text(organization.get('name'));
    this.$manage.attr('href', 'https://accounts.dcloud.org/organizations/' + organization.get('slug'));
    this.$organizationLinks.removeClass('active').filter('[data-organization-id="' + organization.get('id') + '"]').addClass('active');
  },

});
