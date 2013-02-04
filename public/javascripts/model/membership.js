// Memberships Model, links accounts with organizations

dc.model.Membership = Backbone.Model.extend({

  organization: function(){
    return Organizations.get( this.get('organization_id') );
  }

});


dc.model.MemberhipSet = Backbone.Collection.extend({
  model: dc.model.Membership

});


