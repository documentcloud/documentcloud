dc.ui.Entities = dc.View.extend({

  NUM_INITIALLY_VISIBLE : 30,

  id : 'entities',

  callbacks : {
    '.icon.less.click':     'showLess',
    '.icon.more.click':     'showMore',
    '.type_title.click':    'visualizeConnections',
    '.entity.click':        '_openEntity',
    '.entity.mouseenter':   '_highlightDatum',
    '.entity.mouseleave':   '_highlightOff'
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

  isOpen : function() {
    return this._open;
  },

  close : function(e) {
    if (!this._open) return;
    this._open = false;
    this._menu.setLabel('Connections');
    $(document.body).removeClass('visualize');
    $(this.el).html('').hide();
    dc.app.toolbar.setInfo(null);
    dc.history.save(dc.app.searchBox.urlFragment());
  },

  urlFragment : function() {
    return dc.app.searchBox.urlFragment() + '/entities';
  },

  // Prevent multiple calls to render from actually drawing more than once.
  lazyRender : function() {
    if (!this._open) return false;
    var me = this;
    if (me._timeout) clearTimeout(me._timeout);
    me._timeout = setTimeout(function() {
      me._renderEntities();
      me._timeout = null;
    }, 100);
  },

  // Show only the top metadata for the kind.
  showLess : function(e) {
    $(e.target).parents('.entity_list').setMode('less', 'shown');
    return false;
  },

  // Show *all* the metadata for the kind.
  showMore : function(e) {
    $(e.target).parents('.entity_list').setMode('more', 'shown');
    return false;
  },

  visualizeConnections : function(e) {
    dc.app.visualizer.open($(e.target).attr('data-kind'));
  },

  _renderEntities : function() {
    this.collectEntities();
    $(this.el).html('');
    var html = _.map(_.sortBy(this._byKind, function(value, key) {
      return key.toLowerCase();
    }), function(obj) {
      return JST.workspace_entities(obj);
    });
    var docCount = Documents.countSelected();
    $(this.el).html(html.join(''));
    var message = "Displaying " + this._metaCount + ' entities from ' + docCount + ' selected ' + Inflector.pluralize('document', docCount) + '.';
    dc.app.toolbar.setInfo(message);
    this.setCallbacks();
  },

  // Process and separate the metadata out into kinds.
  collectEntities : function() {
    var byKind  = this._byKind = {};
    var max     = this.NUM_INITIALLY_VISIBLE;
    var metas   = Metadata.selected();
    this._metaCount = metas.length;
    _(metas).each(function(meta) {
      var kind = meta.get('kind');
      var list = byKind[kind] = byKind[kind] || {shown : [], rest : [], title : meta.displayKind(), key : kind};
      (list.shown.length < max ? list.shown : list.rest).push(meta);
    });
  },

  _openEntity : function(e) {
    var meta = Metadata.get($(e.target).attr('data-id'));
    $(document.body).append((new dc.ui.EntityDialog(meta)).render().el);
  },

  _highlightDatum : function(e) {
    if ($.browser.msie) return false;
    var id      = $(e.target).attr('data-id');
    var meta    = Metadata.get(id);
    var docIds  = meta.documentIds();
    _.each(Documents.models(), function(doc) {
      if (_(docIds).include(doc.id)) {
        $('#document_' + doc.id).addClass('bolded');
      } else {
        $('#document_' + doc.id).addClass('muted').animate({opacity : 0.5}, {duration : 'fast', queue : false});
      }
    });
  },

  _highlightOff : function(e) {
    if ($.browser.msie) return false;
    $('div.document').removeClass('muted').removeClass('bolded').animate({opacity : 1}, {duration : 'fast', queue : false});
  }

});