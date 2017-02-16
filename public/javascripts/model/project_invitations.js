dc.model.ProjectInvitation = Backbone.Model.extend({

});

dc.model.ProjectInvitationSet = Backbone.Collection.extend({

  model: dc.model.ProjectInvitation,

  url: '/collaborations',

});

window.ProjectInvitations = new dc.model.ProjectInvitationSet();
