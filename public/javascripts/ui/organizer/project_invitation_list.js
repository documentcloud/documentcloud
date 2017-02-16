dc.ui.ProjectInvitationList = Backbone.View.extend({

  events: {
    'click .toggle_hidden': 'toggleHidden'
  },

  initialize: function() {
    this.listenTo(this.collection, 'change', this.render);
    this.showingHidden = false;
    this.render();
  },

  render: function() {
    this.hiddenCount = this.collection.where({hidden: true}).length;
    $(this.el).html(JST['organizer/project_invitation_list']({
      showingHidden:   this.showingHidden,
      hiddenCount:     this.hiddenCount,
      dismissLinkText: this._dismissLinkText()
    }));
    this._renderInvitations();
    return this;
  },

  _renderInvitations: function() {
    var invitations = [];
    this.collection.each(function(invitation) {
      var invitationView = new dc.ui.ProjectInvitation({model: invitation});
      invitations.push(invitationView.render().el);
    });
    this.$('#project_invitation_list').html(invitations);
  },

  _dismissLinkText: function() {
    return (this.showingHidden ? 'Hide ' : 'Show ') + this.hiddenCount + ' dismissed';
  },

  toggleHidden: function() {
    this.showingHidden = !this.showingHidden;
    this.setMode(this.showingHidden ? 'show' : 'hide', 'hidden_project_invitations');
    // TODO: Unhappy with this, but need to think more about how best to change 
    // it without re-rendering the whole list just to toggle.
    this.$('.toggle_hidden').text(this._dismissLinkText());
  },

});
