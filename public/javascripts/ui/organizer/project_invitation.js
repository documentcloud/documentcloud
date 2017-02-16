dc.ui.ProjectInvitation = Backbone.View.extend({

  className: 'project_invitation box',

  events: {
    'click .accept':  'accept',
    'click .dismiss': 'dismiss'
  },

  render: function() {
    this.$el.toggleClass('hidden_invitation', !!this.model.get('hidden'));
    $(this.el).html(JST['organizer/project_invitation'](this.model.toJSON()));
    return this;
  },

  accept: function() {
    // Until the front-end membership-untangling work on the `dc_omniauth` 
    // branch is merged in, always accept via the default membership. The
    // correct UX would be in two stages:
    //   1. Accept via the current membership (chosen by org switcher)
    //   2. Ask the user which org they want to accept the project into
    var membership = dc.account.memberships.findWhere({default: true}) || dc.account.memberships.first();
    if (membership) {
      this.model.save({membership_id: membership.get('id')}, {patch: true});
    } else {
      dc.ui.Dialog.alert('Could not find a membership to accept the project invitation into. This is unexpected. Please contact support.');
    }
  },

  dismiss: function() {
    this.model.save({hidden: true}, {patch: true});
  },

});
