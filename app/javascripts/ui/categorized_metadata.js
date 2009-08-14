dc.ui.CategorizedMetadata = dc.View.extend({
  
  className : 'categorized_metadata',
  
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
      var list = byType[type] = byType[type] || [];
      if (list.length > 5) return;
      list.push(meta);
    });
  },
  
  render : function() {
    $(this.el).html('');
    var html = _.map(this._byType, function(pair) {
      return dc.templates.WORKSPACE_METADATA_LIST(pair);
    });
    $(this.el).html(html.join(''));
    return this;
  }
  
});