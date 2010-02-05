////////////////////////////////////////////////////////
// Although a lot of the surrounding code may be sound,
// this file is SUPER-PROTOTYPE-Y-ONLY!
///////////////////////////////////////////////////////

dc.ui.Visualizer = dc.View.extend({

  id : 'visualizer',

  callbacks : {},

  constructor : function(options) {
    _.bindAll(this, 'open', 'close', 'gatherMetadata', 'renderVisualization', 'highlightDatum', 'highlightOff', 'onResize');
    this.base(options);
    this.topDocuments = [];
    this.topMetadata = [];
    $(window).resize(this.onResize);
    Documents.bind(Documents.SELECTION_CHANGED, this.renderVisualization);
  },

  open : function(kind) {
    this._menu = this._menu || dc.app.toolbar.connectionsMenu;
    this._open = true;
    this._kindFilter = kind;
    this._menu.setLabel('Connections: ' + Metadata.DISPLAY_NAME[kind]);
    this._menu.activate(this.close);
    this.setMode('linear', 'format');
    this._numMetadata = 10;
    $(document.body).addClass('visualize');
    if (Metadata.empty()) return Metadata.populate(this.renderVisualization);
    this.renderVisualization();
  },

  close : function(e) {
    this._open = false;
    this._menu.setLabel('Connections');
    $(document.body).removeClass('visualize');
    $(this.el).html('');
  },

  gatherMetadata : function() {
    this.topDocuments = _(Documents.models()).sortBy(function(doc){ return doc.id; });
    var seenKinds = {};
    var filter = this._kindFilter;
    var meta = _.uniq(_.flatten(_.map(Documents.selected(), function(doc){ return doc.metadata(); })));
    this.topMetadata = _(meta).chain()
      .sortBy(function(meta){ return meta.instanceCount + meta.totalRelevance(); })
      .reverse()
      .select(function(meta){
        return meta.get('kind') == filter;
      })
      .slice(0, this._numMetadata)
      .sortBy(function(meta){ return meta.get('instances')[0].document_id; })
      .value();
  },

  empty : function() {
    return _.isEmpty(this.topMetadata) || _.isEmpty(this.topDocuments);
  },

  highlightDatum : function(e) {
    this._selectedMetaId = e.data.id;
    // TODO -- separate out the canvas repaint from the DOM redraw.
    // this.redrawCanvas();
    var ids = e.data.documentIds();
    // _.each(this.docViews, function(view) {
    //       if (_(ids).include(view.model.id)) {
    //         $(view.el).addClass('bolded');
    //       } else {
    //         $(view.el).addClass('muted').animate({opacity : 0.5}, {duration : 'fast', queue : false});
    //       }
    //     });
  },

  highlightOff : function(e) {
    this._selectedMetaId = null;
    // TODO -- separate out the canvas repaint from the DOM redraw.
    // this.redrawCanvas();
    $('.document_tile', this.el).removeClass('muted').removeClass('bolded').animate({opacity : 1}, {duration : 'fast', queue : false});
  },

  onResize : function() {
    if (this._open && !this.empty()) this.renderVisualization();
  },

  renderVisualization : function() {
    this.gatherMetadata();
    var me = this;
    var el = $(this.el);
    el.html('');
    if (!this._open || this.empty()) return;
    var selectedIds = Documents.selectedIds();

    this.setCallbacks();

    // var maxHeight = _.max([this.topDocuments.length * 100, this.topMetadata.length * 75]);
    // el.css({height : maxHeight});

    var canvas = $.el('canvas', {id : 'visualizer_canvas', width : el.width(), height : el.height()});
    el.append(canvas);
    if (window.G_vmlCanvasManager) G_vmlCanvasManager.initElement(canvas);
    var ctx = canvas.getContext('2d');
    ctx.lineCap = "round";
    ctx.strokeStyle = "#bbb";

    var scale = 0.92 - (150 / el.width());
    var originX = el.width() / 2, originY = el.height() / 2;
    var width = originX * scale, height = originY * scale;
    var piece = Math.PI * 2 / Documents.size();

    scale = 0.4 - (100 / el.width());
    width = originX * scale; height = originY * scale;
    piece = Math.PI * 2 / this.topMetadata.length;

    _.each(this.topMetadata, function(meta, i) {
      var metaEl = $($.el('div', {'class' : 'datum'}, meta.get('value')));
      el.append(metaEl[0]);
      metaEl.bind('mouseenter', meta, me.highlightDatum);
      metaEl.bind('mouseleave', meta, me.highlightOff);
      var position = piece * i;
      var w2 = metaEl.width() / 2, h2 = metaEl.height() / 2;
      metaEl.css({left: 'auto', top: i * 45 + 25, right : 25});

      var pos = metaEl.position();

      _.each(meta.get('instances'), function(instance) {
        var docId = instance.document_id;
        if (selectedIds.indexOf(docId) < 0) return;
        var del   = $('#document_tile_' + docId);
        var dpos  = del.position();
        var docx  = dpos.left + del.width() / 4, docy = dpos.top + del.height() / 2;
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
  }

});