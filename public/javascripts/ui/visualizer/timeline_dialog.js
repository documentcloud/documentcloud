dc.ui.TimelineDialog = dc.ui.Dialog.extend({

  GRAPH_OPTIONS : {
    xaxis   : {mode : 'time', minTickSize: [1, "month"]},
    yaxis   : {ticks: [], min: -0.5},
    legend  : {show : false},
    series  : {lines : {show : false}, points : {show : true}},
    grid    : {hoverable : true, clickable : true}
  },

  ROW_HEIGHT : 50,
  MIN_HEIGHT : 100,

  DATE_FORMAT : "%b %d, %y",

  id : 'timeline_dialog',

  constructor : function(documents) {
    this.documents = documents;
    this.base({
      mode      : 'alert',
      title     : this.displayTitle(),
      text      : ' '
    });
    this.render();
    this._loadDates();
  },

  render : function() {
    this.base();
    var height = this.documents.length <= 1 ? this.MIN_HEIGHT : this.ROW_HEIGHT * this.documents.length;
    this.plot = $($.el('div', {id : 'timeline_plot', style : 'width:800px; height:' + height + 'px;'}));
    $('.text', this.el).append(this.plot);
    $(this.el).align($('#content')[0] || document.body, null, {top : -100});
    this._createTooltip();
    return this;
  },

  displayTitle : function() {
    if (this.documents.length == 1) return 'Timeline for "' + this.documents[0].get('title') + '"';
    return "Timeline for " + this.documents.length + " Documents";
  },

  // Pilfered from http://paulirish.com/2009/random-hex-color-code-snippets/
  randomColor : function() {
    return '#' + Math.floor(Math.random() * 16777215).toString(16);
  },

  _loadDates : function() {
    var dates = _.pluck(this.documents, 'id');
    $.getJSON('/documents/dates', {'ids[]' : dates}, _.bind(this._plotDates, this));
  },

  // Chart the dates for the selected documents.
  _plotDates : function(resp) {
    var me = this;
    var series = {}, styles = {};
    var seriesCount = 0;
    var data = _.each(resp.dates, function(json) {
      var id = json.document_id;
      if (!series[id]) {
        series[id] = [];
        styles[id] = {pos : seriesCount++, color : me.randomColor()};
      }
      series[id].push([json.date * 1000, styles[id].pos]);
    });
    var data = _.map(series, function(val, key) {
      return {data : val, color : styles[key].color, docId : key};
    });
    this.GRAPH_OPTIONS.yaxis.max = seriesCount - 0.5;
    $.plot(this.plot, data, this.GRAPH_OPTIONS);
  },

  // Create a tooltip to show a hovered date.
  _createTooltip : function() {
    var format = this.DATE_FORMAT;
    $(this.plot).bind('plothover', function(e, pos, item) {
      if (!item) return dc.ui.tooltip.hide();
      var title = Documents.get(item.series.docId).get('title');
      var date  = $.plot.formatDate(new Date(item.datapoint[0]), format);
      dc.ui.tooltip.show({
        left : pos.pageX,
        top  : pos.pageY,
        text : title + "<br />" + date
      });
    });
  }

});