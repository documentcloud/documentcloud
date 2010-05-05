// Entity Model

dc.model.Entity = dc.Model.extend({});

// Entity Set

dc.model.EntitySet = dc.Set.extend({

  model : dc.model.Entity,

  // Map of kind to display name for titles and the like.
  DISPLAY_NAME : {
    city          : 'Cities',
    country       : 'Countries',
    date          : 'Dates',
    phone         : 'Phone Numbers',
    organization  : 'Organizations',
    person        : 'People',
    place         : 'Places',
    state         : 'States',
    term          : 'Terms'
  },

  // When rendering entities in a list, use this order:
  ORDER : ['person', 'organization', 'term', 'place', 'city', 'state', 'country'],

  // Fetch a single entity across a set of visible documents.
  fetch : function(kind, value, callback) {
    dc.ui.spinner.show('loading');
    $.get('/documents/entity.json', {'ids[]' : Documents.getIds(), kind : kind, value : value}, function(resp) {
      callback(_.map(resp.entities, function(obj){ return new dc.model.Entity(obj); }));
      dc.ui.spinner.hide();
    }, 'json');
  }

});

window.Entities = new dc.model.EntitySet();