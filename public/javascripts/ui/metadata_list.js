// The MetadataList View shows a categorized expanded/collapsed list of
// metadata for the current Document set.
dc.ui.MetadataList = dc.View.extend({

  className : 'metadata',

  callbacks : [
    ['.toggle .less',           'click',    'showLess'],
    ['.toggle .more',           'click',    'showMore'],
    ['.metalist_title',         'click',    'visualizeKind'],
    ['.metalist_entry_text',    'click',    'addToSearch'],
    ['.metalist_entry_text',    'dblclick', 'addThenSearch']
  ],

  // Think about limiting the initially visible metadata to ones that are above
  // a certain relevance threshold, showing at least three, or something along
  // those lines.
  NUM_INITIALLY_VISIBLE : 5,

  // Process and separate the metadata out into kinds.
  collectMetadata : function() {
    var byKind  = this._byKind = {};
    var max     = this.NUM_INITIALLY_VISIBLE;
    _(Metadata.selected(true)).each(function(meta) {
      var kind = meta.get('kind');
      var list = byKind[kind] = byKind[kind] || {shown : [], rest : [], title : meta.displayKind()};
      (list.shown.length < max ? list.shown : list.rest).push(meta);
    });
  },

  // Render...
  render : function() {
    this.collectMetadata();
    $(this.el).html('');
    var html = _.map(this._byKind, function(value, key) {
      return JST.workspace_metalist({key : key, value : value});
    });
    $(this.el).html(html.join(''));
    $('#metadata_container').html(this.el);
    this.setCallbacks();
    return this;
  },

  // TODO: Move this into the appropriate controller.
  addToSearch : function(e) {
    var metaId = $(e.target).attr('metadatum_id');
    var meta = Metadata.get(metaId);
    var search = meta.toSearchQuery();
    var searchField = dc.app.searchBox.el;
    if (searchField.value.indexOf(search) > 0) return;
    var endsWithSpace = !!searchField.value.match(/\s$/);
    searchField.value += ((endsWithSpace ? '' : ' ') + search);
  },

  // TODO: Move this ''
  addThenSearch : function(e) {
    this.addToSearch(e);
    dc.app.searchBox.search($('#search').val());
  },

  visualizeKind : function(e) {
    if (dc.app.navigation.currentTab != 'visualize') return;
    var kind = $(e.target).attr('data-kind');
    dc.app.workspace.visualizer.visualize(kind);
  },

  // Show only the top metadata for the kind.
  showLess : function(e) {
    $(e.target).parents('.metalist').setMode('less', 'shown');
  },

  // Show *all* the metadata for the kind.
  showMore : function(e) {
    $(e.target).parents('.metalist').setMode('more', 'shown');
  }

});