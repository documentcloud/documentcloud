////////////////////////////////////////////////////////
// Although a lot of the surrounding code may be sound,
// this file is SUPER-PROTOTYPE-Y-ONLY!
///////////////////////////////////////////////////////

dc.ui.Visualizer = dc.View.extend({

  id : 'visualizer',

  callbacks : [
    ['#viz_circle',     'click',    'renderCircular'],
    ['#viz_line',       'click',    'renderLinear']
  ],

  constructor : function(options) {
    _.bindAll('open', 'renderVisualization', 'highlightDatum', 'highlightOff', 'onResize', this);
    this.base(options);
    this.topDocuments = [];
    this.topMetadata = [];
    dc.app.navigation.register('visualize', this.open);
    $(window).resize(this.onResize);
    Documents.bind(Documents.SELECTION_CHANGED, this.renderVisualization);
  },

  open : function() {
    this._kindFilter = null;
    this.setMode('linear', 'format');
    this._numMetadata = 10;
    this.gatherMetadata();
    _.defer(this.renderVisualization);
  },

  visualize : function(kind) {
    this._kindFilter = kind;
    this.gatherMetadata();
    this.renderVisualization();
  },

  gatherMetadata : function() {
    this.topDocuments = _(Documents.models()).sortBy(function(doc){ return doc.id; });
    var seenKinds = {};
    var filter = this._kindFilter;
    this.topMetadata = _(Metadata.models()).chain()
      .sortBy(function(meta){ return meta.instanceCount + meta.totalRelevance(); })
      .reverse()
      .select(function(meta){
        var kind = meta.get('kind');
        if (filter) {
          return (kind == filter);
        } else {
          if (_(['country', 'province_or_state', 'category']).include(kind)) return false;
          if (seenKinds[kind]) return false;
          return seenKinds[kind] = true;
        }
      })
      .slice(0, this._numMetadata)
      .sortBy(function(meta){ return meta.get('instances')[0].document_id; })
      .value();
  },

  renderCircular : function() {
    this.setMode('circular', 'format');
    this._numMetadata = 7;
    this.gatherMetadata();
    this.renderVisualization();
  },

  renderLinear : function() {
    this.setMode('linear', 'format');
    this._numMetadata = 10;
    this.gatherMetadata();
    this.renderVisualization();
  },

  empty : function() {
    return _.isEmpty(this.topMetadata);
  },

  highlightDatum : function(e) {
    this._selectedMetaId = e.data.id;
    // TODO -- separate out the canvas repaint from the DOM redraw.
    // this.redrawCanvas();
    var ids = e.data.documentIds();
    _.each(this.docViews, function(view) {
      if (_(ids).include(view.model.id)) {
        $(view.el).addClass('bolded');
      } else {
        $(view.el).addClass('muted').animate({opacity : 0.5}, {duration : 'fast', queue : false});
      }
    });
  },

  highlightOff : function(e) {
    this._selectedMetaId = null;
    // TODO -- separate out the canvas repaint from the DOM redraw.
    // this.redrawCanvas();
    $('.document_tile', this.el).removeClass('muted').removeClass('bolded').animate({opacity : 1}, {duration : 'fast', queue : false});
  },

  onResize : function() {
    if (dc.app.navigation.currentTab == 'visualize' && !this.empty()) this.renderVisualization();
  },

  renderVisualization : function() {
    if (this.empty()) return;
    var me = this;
    var el = $(this.el);
    el.html('');
    this.docViews = [];
    var selectedIds = Documents.selectedIds();
    var linear = this.modes.format == 'linear';

    var title = (this._kindFilter ? Metadata.KIND_MAP[this._kindFilter] : 'Most Relevant') + ':';
    el.append($.el('div', {id : 'visualization_title'}, title));

    var links = $.el('div', {id : 'viz_types'}, '<span id="viz_line">linear</span> | <span id="viz_circle">circular</span>');
    var links = el.append(links);
    this.setCallbacks();

    el.append($.el('div', {id :'viz_inner_wrapper'}, $.el('div', {id :'viz_inner'})));
    el = $('#viz_inner');
    if (linear) {
      var maxHeight = _.max([this.topDocuments.length * 100, this.topMetadata.length * 75]);
      el.css({height : maxHeight});
    } else {
      el.css({height : $(this.el).height()});
    }

    var canvas = $.el('canvas', {id : 'visualizer_canvas', width : el.width(), height : el.height()});
    el.append(canvas);
    var ctx = canvas.getContext('2d');
    ctx.lineCap = "round";

    var scale = 0.92 - (150 / el.width());
    var originX = el.width() / 2, originY = el.height() / 2;
    var width = originX * scale, height = originY * scale;
    var piece = Math.PI * 2 / Documents.size();

    _.each(this.topDocuments, function(doc, i) {
      var tile = new dc.ui.DocumentTile(doc, 'viz').render();
      me.docViews.push(tile);
      el.append(tile.el);
      var position = piece * i;
      $(tile.el).css({
        left: Math.cos(position) * width + originX - 110,
        top: Math.sin(position) * height + originY - 40
      });
    });

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
      if (linear) {
        metaEl.css({left: 'auto', top: i * 75 + 25, right : 25});
      } else {
        metaEl.css({
          left: Math.cos(position) * width + originX - w2,
          top: Math.sin(position) * height + originY - h2,
          right: 'auto'
        });
      }
      var pos = metaEl.position();

      _.each(meta.get('instances'), function(instance) {
        var docId = instance.document_id;
        var del   = $('#document_viz_' + docId);
        var dpos  = del.position();
        var docx  = dpos.left + del.width() / 4, docy = dpos.top + del.height() / 2;
        ctx.strokeStyle = (meta.id == me._selectedMetaId) ? '#e57777' : _(selectedIds).include(docId) ? "#abafe5" : "#bbb";
        ctx.globalAlpha = instance.relevance * 0.9 + 0.1;
        ctx.lineWidth = instance.relevance * 20 + 1;
        ctx.beginPath();
        ctx.moveTo(pos.left + w2, pos.top + h2);
        if (linear) {
          ctx.bezierCurveTo(pos.left + w2 - originX,
                            pos.top + h2,
                            docx + originX, docy,
                            docx, docy);
        } else {
          ctx.bezierCurveTo(Math.cos(position) * width * 2.5 + originX - w2,
                            Math.sin(position) * height * 2.5 + originY - h2,
                            docx, docy,
                            docx, docy);
        }
        ctx.stroke();
      });
    });
  }

});