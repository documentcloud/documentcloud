////////////////////////////////////////////////////////
// Although a lot of the surrounding code may be sound,
// this file is SUPER-PROTOTYPE-Y-ONLY!
///////////////////////////////////////////////////////

dc.ui.Visualizer = dc.View.extend({

  ENTITY_LIMIT : 15,

  id : 'visualizer',

  callbacks : {
    '.datum.click':       '_openEntity',
    '.datum.mouseenter':  '_highlightDatum',
    '.datum.mouseleave':  '_highlightOff'
  },

  constructor : function(options) {
    _.bindAll(this, 'open', 'close', 'gatherEntities', 'lazyRender', 'highlightDatum', 'highlightOff', 'onResize');
    this.base(options);
    this.topEntities = [];
    $(window).resize(this.onResize);
    $(this.el).hide();
    Documents.bind(Documents.SELECTION_CHANGED, this.lazyRender);
  },

  open : function(kind) {
    dc.app.entities.close();
    this._menu = this._menu || dc.app.toolbar.connectionsMenu;
    this._open = true;
    this._kindFilter = kind;
    this._menu.setLabel('Connections: ' + Entities.DISPLAY_NAME[kind]);
    this._menu.activate(this.close);
    this.setMode('linear', 'format');
    $(document.body).addClass('visualize');
    $(this.el).show();
    dc.history.save(this.urlFragment());
    if (Entities.empty()) return Entities.populate(this.lazyRender);
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
    dc.history.save(dc.app.searchBox.urlFragment());
  },

  urlFragment : function() {
    return dc.app.searchBox.urlFragment() + '/connections/' + this._kindFilter;
  },

  gatherEntities : function() {
    var seenKinds = {};
    var filter    = this._kindFilter;
    var docIds    = Documents.selectedIds();
    var meta      = _.uniq(_.flatten(_.map(Documents.selected(), function(doc){ return doc.entities(); })));
    this.topEntities = _(meta).chain()
      .sortBy(function(meta){ return meta.instanceCount + meta.totalRelevance(); })
      .reverse()
      .select(function(meta){
        return meta.get('kind') == filter;
      })
      .slice(0, this.ENTITY_LIMIT)
      .sortBy(function(meta){ return _.indexOf(docIds, meta.firstId()); })
      .value();
  },

  empty : function() {
    return _.isEmpty(this.topEntities) || Documents.empty();
  },

  onResize : function() {
    if (this._open && !this.empty()) this._renderVisualization();
  },

  // Prevent multiple calls to render from actually drawing more than once.
  lazyRender : function() {
    var me = this;
    if (me._timeout) clearTimeout(me._timeout);
    me._timeout = setTimeout(function() {
      me._renderVisualization();
      me._timeout = null;
    }, 100);
  },

  _renderVisualization : function() {
    this.gatherEntities();
    var me = this;
    var el = $(this.el);
    el.html('');
    if (!this._open) return;
    if (this.empty()) return el.html('<div class="emptyviz">No selected documents.</div>');
    var selectedIds = Documents.selectedIds();

    var canvas = $.el('canvas', {id : 'visualizer_canvas', width : el.width(), height : $('.panel_container').height()});
    el.append(canvas);
    if (window.G_vmlCanvasManager) G_vmlCanvasManager.initElement(canvas);
    var ctx = canvas.getContext('2d');
    ctx.lineCap = "round";
    ctx.strokeStyle = "#c5c5e5";

    var scale = 0.92 - (150 / el.width());
    var originX = el.width() / 2, originY = el.height() / 2;
    var width = originX * scale, height = originY * scale;
    var piece = Math.PI * 2 / Documents.size();

    scale = 0.4 - (100 / el.width());
    width = originX * scale; height = originY * scale;
    piece = Math.PI * 2 / this.topEntities.length;

    _.each(this.topEntities, function(meta, i) {
      var metaEl = $($.el('div', {'class' : 'datum gradient_light', 'data-id' : meta.id}, meta.get('value')));
      el.append(metaEl[0]);
      var position = piece * i;
      var w2 = metaEl.outerWidth() / 2, h2 = metaEl.outerHeight() / 2;
      metaEl.css({left: 'auto', top: i * 40 + 25, right : 25});

      var pos = metaEl.position();

      _.each(Entities.uniqueInstancesByDocument(meta.get('instances')), function(instance) {
        var docId = instance.document_id;
        if (_.indexOf(selectedIds, docId) < 0) return;
        var del   = $('#document_' + docId);
        var dpos  = del.position();
        var docx  = dpos.left + 20, docy = dpos.top + del.outerHeight() / 2;
        ctx.globalAlpha = instance.relevance * 0.5 + 0.25;
        ctx.lineWidth = instance.relevance * 20 + 1;
        ctx.beginPath();
        ctx.moveTo(pos.left + w2, pos.top + h2);
        ctx.bezierCurveTo(pos.left + w2 - originX,
                          pos.top + h2,
                          docx + originX, docy,
                          docx, docy);
        ctx.stroke();
      });
    });

    this.setCallbacks();
  },

  _openEntity : function(e) {
    var meta = Entities.get($(e.target).attr('data-id'));
    $(document.body).append((new dc.ui.EntityDialog(meta)).render().el);
    return false;
  },

  _highlightDatum : function(e) {
    // var meta = Entities.get($(e.target).attr('data-id'));
    // var ids = meta.documentIds();
    // _.each(Documents.models(), function(doc) {
    //   if (_(ids).include(doc.id)) {
    //     $('#document_' + doc.id).addClass('bolded');
    //   } else {
    //     $('#document_' + doc.id).addClass('muted').animate({opacity : 0.5}, {duration : 'fast', queue : false});
    //   }
    // });
  },

  _highlightOff : function(e) {
    // $('div.document').removeClass('muted').removeClass('bolded').animate({opacity : 1}, {duration : 'fast', queue : false});
  }

});