// Entity Model

dc.model.Entity = dc.Model.extend({

}, {

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
    dc.ui.spinner.show();
    $.get('/documents/entity.json', {'ids[]' : Documents.getIds(), kind : kind, value : value}, function(resp) {
      callback(_.map(resp.entities, function(obj){ return new dc.model.Entity(obj); }));
      dc.ui.spinner.hide();
    }, 'json');
  }

});

// Entity Set

dc.model.EntitySet = dc.Set.extend({

  model : dc.model.Entity,

  comparator : function(entity) {
    var pages = _.pluck(entity.get('excerpts'), 'page_number');
    return Math.min.apply(Math, pages);
  }

});

dc.model.EntitySet.implement(dc.model.SortedSet);

window.EntityDates = new dc.model.EntitySet();

EntityDates.comparator = function(entity) {
  return entity.get('date');
};
