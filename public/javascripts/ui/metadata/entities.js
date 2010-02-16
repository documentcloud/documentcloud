dc.ui.Entities = dc.View.extend({

  // Think about limiting the initially visible metadata to ones that are above
  // a certain relevance threshold, showing at least three, or something along
  // those lines.
  NUM_INITIALLY_VISIBLE : 5,

  id : 'entities',

  callbacks : {
    '.icon.less.click':         'showLess',
    '.icon.more.click':         'showMore',
    '.metalist_title.click':    'visualizeKind',
    '.jump_to.click':           '_openDocument'
  },

  constructor : function(options) {
    _.bindAll(this, 'lazyRender', 'open', 'close', '_renderEntities');
    this.base(options);
    $(this.el).hide();
    Documents.bind(Documents.SELECTION_CHANGED, this.lazyRender);
  },

  open : function(kind) {
    dc.app.visualizer.close();
    this._menu = this._menu || dc.app.toolbar.connectionsMenu;
    this._open = true;
    this._menu.setLabel('Entities');
    this._menu.activate(this.close);
    $(document.body).addClass('visualize');
    $(this.el).show();
    dc.history.save(this.urlFragment());
    if (Metadata.empty()) return Metadata.populate(this.lazyRender);
    this.lazyRender();
  },

  close : function(e) {
    if (!this._open) return;
    this._open = false;
    this._menu.setLabel('Connections');
    $(document.body).removeClass('visualize');
    $(this.el).html('').hide();
    dc.history.save(dc.app.searchBox.urlFragment());
  },

  urlFragment : function() {
    return dc.app.searchBox.urlFragment() + '/entities';
  },

  // Prevent multiple calls to render from actually drawing more than once.
  lazyRender : function() {
    var me = this;
    if (me._timeout) clearTimeout(me._timeout);
    me._timeout = setTimeout(function() {
      me._renderEntities();
      me._timeout = null;
    }, 100);
  },

  // Show only the top metadata for the kind.
  showLess : function(e) {
    $(e.target).parents('.metalist').setMode('less', 'shown');
  },

  // Show *all* the metadata for the kind.
  showMore : function(e) {
    $(e.target).parents('.metalist').setMode('more', 'shown');
  },

  _renderEntities : function() {
    this.collectEntities();
    $(this.el).html('');
    var html = _.map(this._byKind, function(value, key) {
      return JST.workspace_metalist({key : key, value : value});
    });
    $(this.el).html(html.join(''));
    this.setCallbacks();
  },

  // Process and separate the metadata out into kinds.
  collectEntities : function() {
    var byKind  = this._byKind = {};
    var max     = this.NUM_INITIALLY_VISIBLE;
    _(Metadata.selected()).each(function(meta) {
      var kind = meta.get('kind');
      var list = byKind[kind] = byKind[kind] || {shown : [], rest : [], title : meta.displayKind()};
      (list.shown.length < max ? list.shown : list.rest).push(meta);
    });
  },

  _openDocument : function(e) {
    var metaId  = $(e.target).attr('data-id');
    var meta    = Metadata.get(metaId);
    var inst    = meta.get('instances')[0];
    var doc     = Documents.get(inst.document_id);
    window.open(doc.get('document_viewer_url') + "?entity=" + inst.id);
  }

});