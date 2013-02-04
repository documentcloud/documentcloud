// Memberships Model, links accounts with organizations

dc.model.Membership = Backbone.Model.extend({

  organization: function(){
    return Organizations.get( this.get('organization_id') );
  }

});


dc.model.MemberhipSet = Backbone.Collection.extend({
  model: dc.model.Membership,


  getDefault: function(){
    return this.detect( function(membership){
      return true === membership.get('default');
    }) || this.first() || new this.model;
  },

  setDefault: function( default_membership ){
    this.each( function(membership){
      membership.set('default', membership.id == default_membership.id );
    });
  }

});


