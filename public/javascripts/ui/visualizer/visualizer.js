dc.ui.Visualizer = dc.View.extend({

  id : 'visualizer',

  callbacks : [],

  constructor : function(options) {
    _.bindAll('renderVisualization', 'open', this);
    this.base(options);
    dc.app.navigation.register('visualize', this.open);
    $(window).resize(this.renderVisualization);
  },

  open : function() {
    this._kindFilter = null;
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
      .slice(0,7)
      .sortBy(function(meta){ return meta.get('instances')[0].document_id; })
      .value();
  },

  renderVisualization : function() {
    if (this.topMetadata.length == 0) return;
    var el = $(this.el);
    el.html('');

    var title = (this._kindFilter ? Metadata.KIND_MAP[this._kindFilter] : 'Most Relevant') + ':';
    el.append($.el('div', {id : 'visualization_title'}, title));

    var canvas = $.el('canvas', {id : 'visualizer_canvas', width : el.width(), height : el.height()});
    el.append(canvas);
    var ctx = canvas.getContext('2d');
    ctx.strokeStyle = "#abafe5";
    ctx.lineCap = "round";

    var scale = 0.9 - (150 / el.width());
    var originX = el.width() / 2, originY = el.height() / 2;
    var width = originX * scale, height = originY * scale;
    var piece = Math.PI * 2 / Documents.size();
    var docViews = [];

    _.each(this.topDocuments, function(doc, i) {
      var tile = new dc.ui.DocumentTile(doc, 'viz').render();
      docViews.push(tile);
      el.append(tile.el);
      var position = piece * i;
      $(tile.el).css({
        left: Math.cos(position) * width + originX - 100,
        top: Math.sin(position) * height + originY - 50
      });
    });

    scale = 0.4 - (100 / el.width());
    width = originX * scale; height = originY * scale;
    piece = Math.PI * 2 / this.topMetadata.length;

    _.each(this.topMetadata, function(meta, i) {
      var metaEl = $($.el('div', {'class' : 'metaviz'}, meta.get('value')));
      el.append(metaEl[0]);
      var position = piece * i;
      var w2 = metaEl.width() / 2, h2 = metaEl.height() / 2;
      metaEl.css({
        left: Math.cos(position) * width + originX - w2,
        top: Math.sin(position) * height + originY - h2
      });
      var pos = metaEl.position();

      _.each(meta.get('instances'), function(instance) {
        var del = $('#document_viz_' + instance.document_id);
        var dpos = del.position();
        var docx = dpos.left + del.width() / 4, docy = dpos.top + del.height() / 2;
        ctx.globalAlpha = instance.relevance * 0.9 + 0.1;
        ctx.lineWidth = instance.relevance * 20 + 1;
        ctx.beginPath();
        ctx.moveTo(pos.left + w2, pos.top + h2);
        ctx.bezierCurveTo(Math.cos(position) * width * 2.5 + originX - w2,
                          Math.sin(position) * height * 2.5 + originY - h2,
                          docx, docy,
                          docx, docy);
        ctx.stroke();
      });
    });
  }

});