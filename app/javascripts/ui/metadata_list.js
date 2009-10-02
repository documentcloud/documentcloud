// The MetadataList View shows a categorized expanded/collapsed list of
// metadata for the current Document set.
dc.ui.MetadataList = dc.View.extend({
  
  className : 'metadata',
  
  callbacks : [
    ['.toggle .less',           'click',    'showLess'],
    ['.toggle .more',           'click',    'showMore'],
    ['.metalist_entry_text',    'click',    'addToSearch'],
    ['.metalist_entry_text',    'dblclick', 'addThenSearch']
  ],
  
  // Think about limiting the initially visible metadata to ones that are above
  // a certain relevance threshold, showing at least three, or something along
  // those lines.
  NUM_INITIALLY_VISIBLE : 5,
  
  // At creation, pass in a sorted array of metadata options.metadata.
  constructor : function(options) {
    this.base(options);
    this.mapMetadata();
  },
  
  // Process and separate the metadata out into types.
  mapMetadata : function() {
    var byType = this._byType = {};
    var max = this.NUM_INITIALLY_VISIBLE;
    _.each(this.options.metadata, function(meta) {
      var type = meta.get('type');
      var list = byType[type] = byType[type] || {shown : [], rest : [], title : meta.displayType()};
      (list.shown.length < max ? list.shown : list.rest).push(meta);
    });
  },
  
  // Render...
  render : function() {
    $(this.el).html('');
    var html = _.map(this._byType, function(pair) {
      return dc.templates.WORKSPACE_METALIST(pair);
    });
    $(this.el).html(html.join(''));
    this.setCallbacks();
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
    dc.app.workspace.search($('#searc').val());
  },
  
  // Show only the top metadata for the type.
  showLess : function(e) {
    $.setMode($(e.target).parents('.metalist').get(0), 'less', 'shown');
  },
  
  // Show *all* the metadata for the type.
  showMore : function(e) {
    $.setMode($(e.target).parents('.metalist').get(0), 'more', 'shown');
  }
  
});