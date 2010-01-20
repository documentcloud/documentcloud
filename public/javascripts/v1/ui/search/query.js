// The Query is the plain-text, plain-english representation of the thing
// that you just searched for.
dc.ui.Query = dc.View.extend({

  QUOTED : /^['"].+['"]$/,

  className : 'search_query',

  constructor : function(options) {
    this.base(options);
    Documents.bind(Documents.SELECTION_CHANGED, _(this._onSelectionChange).bind(this));
  },

  blank : function() {
    $(this.el).html('');
  },

  render : function(data, count) {
    data = data ? (this.data = data) : this.data;
    var to = Math.min(data.to, data.total);
    var fromPart = (data.total < 2 ? '' : '' + (data.from + 1) + " &ndash; " + to + " of ");
    var sentence = fromPart + data.total + " document" + (data.total == 1 ? "" : "s") + ' matching ';
    var fields = data.fields.concat(data.attributes);
    var list = $.map(fields, function(f){ return f.value; });
    list = list.concat(data.projects);
    if (data.text) list.push(data.text);
    var me = this;
    list = $.map(list, function(s) {
      return me.QUOTED.test(s) ? s : '"' + s + '"';
    });
    var last = list.pop();

    var query = (list.length == 0) ? last :
                (list.length == 1) ? list[0] + ' and ' + last :
                                     list.join(', ') + ", and " + last;

    sentence += (query + '.');
    $(this.el).html(sentence);
    if (count === 0) $('#no_results_query').html('&ndash; ' + query + ' &ndash; ');
    return this;
  },

  renderSelected : function(count) {
    var sentence = count + ' selected ' + Inflector.pluralize('document', count) + '.';
    $(this.el).html(sentence);
  },

  _onSelectionChange : function() {
    var count = Documents.countSelected();
    count > 0 ? this.renderSelected(count) : this.render(null, count);
  }

});