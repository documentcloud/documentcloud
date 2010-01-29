// The MetadataList View shows a categorized expanded/collapsed list of
// metadata for the current Document set.
dc.ui.MetadataList = dc.View.extend({

  className : 'metadata',

  callbacks : [
    ['.toggle .less',       'click',      'showLess'],
    ['.toggle .more',       'click',      'showMore'],
    ['.metalist_title',     'click',      'visualizeKind'],
    ['.add_to_search',      'click',      '_addToSearch'],
    ['.add_to_search',      'dblclick',   '_addThenSearch'],
    ['.jump_to',            'click',      '_openDocument']
  ],

  // Think about limiting the initially visible metadata to ones that are above
  // a certain relevance threshold, showing at least three, or something along
  // those lines.
  NUM_INITIALLY_VISIBLE : 5,

  constructor : function(options) {
    this.base(options);
    _.bindAll(this, 'render');
    Documents.bind(Documents.SELECTION_CHANGED, this.render);
  },

  // Process and separate the metadata out into kinds.
  collectMetadata : function() {
    var byKind  = this._byKind = {};
    var max     = this.NUM_INITIALLY_VISIBLE;
    _(Metadata.models()).each(function(meta) {
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
  _addToSearch : function(e) {
    var metaId = $(e.target).attr('data-id');
    var meta = Metadata.get(metaId);
    var search = meta.toSearchQuery();
    var searchField = dc.app.searchBox.el;
    if (searchField.value.indexOf(search) > 0) return;
    var endsWithSpace = !!searchField.value.match(/\s$/);
    searchField.value += ((endsWithSpace ? '' : ' ') + search);
  },

  // TODO: Move this ''
  _addThenSearch : function(e) {
    this.addToSearch(e);
    dc.app.searchBox.search(dc.app.searchBox.value());
  },

  _openDocument : function(e) {
    var metaId  = $(e.target).attr('data-id');
    var meta    = Metadata.get(metaId);
    var inst    = meta.get('instances')[0];
    var doc     = Documents.get(inst.document_id);
    window.open(doc.get('document_viewer_url') + "?entity=" + inst.id);
  },

  visualizeKind : function(e) {
    if (dc.app.navigation.currentTab != 'analyze') return;
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