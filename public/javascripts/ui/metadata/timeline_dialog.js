dc.ui.TimelineDialog = dc.ui.Dialog.extend({

  GRAPH_OPTIONS : {
    xaxis     : {mode : 'time', minTickSize: [1, "day"]},
    yaxis     : {ticks: [], min: -0.5},
    selection : {mode : 'x', color: '#09f'},
    legend    : {show : false},
    series    : {lines : {show : false}, points : {show : true}},
    grid      : {backgroundColor: '#222', borderColor: '#444', tickColor: '#282828', borderWidth: 1, hoverable : true, clickable : true}
  },

  ROW_HEIGHT : 50,
  MIN_HEIGHT : 100,

  DATE_FORMAT : "%b %d, %y",

  POINT_COLOR : '#777',

  id : 'timeline_dialog',

  callbacks : {
    '.zoom_out.click':              '_zoomOut',
    '.ok.click':                    'confirm',
    '.timeline_plot.plothover':     '_showTooltop',
    '.timeline_plot.plotselected':  '_zoomIn',
    '.timeline_plot.plotclick':     '_openPage'
  },

  constructor : function(documents) {
    this.documents = documents;
    this.base({
      mode        : 'custom',
      title       : this.displayTitle(),
      information : 'Drag a range of dates to zoom in.'
    });
    dc.ui.spinner.show();
    this._loadDates();
  },

  render : function() {
    this.base();
    $('.custom', this.el).html(JST.timeline({docs : this.documents, minHeight : this.MIN_HEIGHT, rowHeight : this.ROW_HEIGHT}));
    this._zoomButton = $.el('div', {'class' : 'minibutton zoom_out dark not_enabled'}, 'Zoom Out');
    $('.controls_inner', this.el).append(this._zoomButton);
    this.setCallbacks();
    this.center();
    return this;
  },

  displayTitle : function() {
    if (this.documents.length == 1) return 'Timeline for "' + this.documents[0].get('title') + '"';
    return "Timeline for " + this.documents.length + " Documents";
  },

  // Redraw the Flot Plot.
  drawPlot : function() {
    $.plot($('.timeline_plot', this.el), this._data, this._options);
  },

  _loadDates : function() {
    var dates = _.pluck(this.documents, 'id');
    $.getJSON('/documents/dates', {'ids[]' : dates}, _.bind(this._plotDates, this));
  },

  // Chart the dates for the selected documents.
  _plotDates : function(resp) {
    dc.ui.spinner.hide();
    if (resp.dates.length == 0) return this._noDates();
    this.render();
    var color = this.POINT_COLOR;
    var series = {}, styles = {};
    var seriesCount = 0;
    var data = _.each(resp.dates, function(json) {
      var id = json.document_id;
      if (!series[id]) {
        series[id] = [];
        styles[id] = {pos : seriesCount++, color : color};
      }
      series[id].push([json.date * 1000, styles[id].pos]);
    });
    this._data = _.map(series, function(val, key) {
      return {data : val, color : styles[key].color, docId : parseInt(key, 10)};
    });
    this._options = _.clone(this.GRAPH_OPTIONS);
    this._options.xaxis.min = null;
    this._options.xaxis.max = null;
    this._options.yaxis.max = seriesCount - 0.5;
    this.drawPlot();
  },

  // Create a tooltip to show a hovered date.
  _showTooltop : function(e, pos, item) {
    if (!item) return dc.ui.tooltip.hide();
    var title = Inflector.truncate(Documents.get(item.series.docId).get('title'), 35);
    var date  = $.plot.formatDate(new Date(item.datapoint[0]), this.DATE_FORMAT);
    dc.ui.tooltip.show({
      left : pos.pageX,
      top  : pos.pageY,
      text : title + "<br />" + date
    });
  },

  // Allow clicking on date ranges to jump to the page containing the date
  // in the document.
  _openPage : function(e, pos, item) {
    var unixTime = item.datapoint[0] / 1000;
    var doc = Documents.get(item.series.docId);
    window.open(doc.get('document_viewer_url') + "?date=" + unixTime);
  },

  // Allow selection of date ranges to zoom in.
  _zoomIn : function(e, ranges) {
    $(this._zoomButton).setMode('is', 'enabled');
    this._options.xaxis.min = ranges.xaxis.from;
    this._options.xaxis.max = ranges.xaxis.to;
    this.drawPlot();
  },

  // Zoom back out to see the entire timeline.
  _zoomOut : function() {
    $(this._zoomButton).setMode('not', 'enabled');
    this._options.xaxis.min = null;
    this._options.xaxis.max = null;
    this.drawPlot();
  },

  // Close, with an error, when no dates are found.
  _noDates : function() {
    var count = this.documents.length;
    this.close();
    var message = "None of the " + count + " documents contained recognizable dates.";
    if (count <= 1) message = '"' + this.documents[0].get('title') + '" does not contain any recognizable dates.';
    dc.ui.Dialog.alert(message);
  }

});