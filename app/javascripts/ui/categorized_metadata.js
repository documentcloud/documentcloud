dc.ui.CategorizedMetadata = dc.View.extend({
  
  className : 'categorized_metadata',
  
  callbacks : [
    ['.toggle .less',           'click',    'showLess'],
    ['.toggle .more',           'click',    'showMore'],
    ['.metalist_entry_text',    'click',    'addToSearch'],
    ['.metalist_entry_text',    'dblclick', 'addThenSearch']
  ],
  
  // At creation, pass in a sorted array of metadata options.metadata.
  constructor : function(options) {
    this.base(options);
    this.mapMetadata();
  },
  
  // Separate the metadata out. ONLY RENDERS THE TOP 5.
  mapMetadata : function() {
    var byType = this._byType = {};
    _.each(this.options.metadata, function(meta) {
      var type = meta.get('type');
      var list = byType[type] = byType[type] || {shown : [], rest : []};
      (list.shown.length < 5 ? list.shown : list.rest).push(meta);
    });
  },
  
  render : function() {
    $(this.el).html('');
    var html = _.map(this._byType, function(pair) {
      return dc.templates.WORKSPACE_METALIST(pair);
    });
    $(this.el).html(html.join(''));
    return this;
  },
  
  // TODO: Move this into the appropriate controller.
  addToSearch : function(e) {
    var metaId = $(e.target).attr('metadatum_id'); 
    var meta = Metadata.get(metaId);
    var search = meta.toSearchQuery();
    var searchField = $('#search').get(0);
    if (searchField.value.indexOf(search) > 0) return;
    var endsWithSpace = !!searchField.value.match(/\s$/);
    searchField.value += ((endsWithSpace ? '' : ' ') + search);
  },
  
  // TODO: Move this ''
  addThenSearch : function(e) {
    this.addToSearch(e);
    $('#search').triggerHandler('keydown');
  },
  
  showLess : function(e) {
    $.setMode($(e.target).parents('.metalist').get(0), 'less', 'shown');
  },
  
  showMore : function(e) {
    $.setMode($(e.target).parents('.metalist').get(0), 'more', 'shown');
  }
  
});