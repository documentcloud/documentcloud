dc.model.SearchFacet = Backbone.Model.extend({
  
  QUOTABLE_CATEGORIES : [
    'project',
    'city',
    'country',
    'term',
    'state',
    'person',
    'place',
    'organization',
    'email',
    'phone'
  ],
  
  serialize : function() {
    var category = this.get('category');
    var value    = dc.inflector.trim(this.get('value'));
    
    if (!value) return '';
    
    if (_.contains(this.QUOTABLE_CATEGORIES, category)) value = '"' + value + '"';
    
    if (category != 'text') {
      category = category + ': ';
    } else {
      category = "";
    }
    
    return category + value;
  }
  
});