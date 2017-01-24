dc.model.Membership = Backbone.Model.extend({

  // Keep in sync with roles.rb
  DISABLED           : 0,
  ADMINISTRATOR      : 1,
  CONTRIBUTOR        : 2,
  REVIEWER           : 3,
  FREELANCER         : 4,

  // NB: Indexed by role number.
  ROLE_NAMES         : ['disabled', 'administrator', 'contributor', 'reviewer', 'freelancer'],

  isAdmin: function() {
    return this.get('role') == this.ADMINISTRATOR;
  },

  isContributor: function() {
    return this.get('role') == this.CONTRIBUTOR;
  },

  isReviewer: function() {
    return this.get('role') == this.REVIEWER;
  },

  isReal: function() {
    return _.contains([this.ADMINISTRATOR, this.CONTRIBUTOR, this.FREELANCER], this.get('role'));
  },

  setCurrent: function() {
    dc.app.preferences.set({current_membership_id: this.get('id')});
  },

});

dc.model.MembershipSet = Backbone.Collection.extend({

  model: dc.model.Membership,

  default: function() {
    return this.findWhere({default: true});
  },

  current: function() {
    var currentMembershipId = dc.app.preferences.get('current_membership_id');
    return this.get(currentMembershipId) || this.default();
  },

  setCurrent: function(membershipId) {
    this.get(parseInt(membershipId, 10)).setCurrent();
  },

});