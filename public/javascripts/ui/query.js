// The Query is the plain-text, plain-english representation of the thing
// that you just searched for.
dc.ui.Query = dc.View.extend({
  
  QUOTED : /^['"].+['"]$/,
  
  className : 'search_query',
    
  render : function() {
    var data = this.options;
    var to = Math.min(data.to, data.total);
    var sentence = '' + (data.from + 1) + " &ndash; " + to + " of " + data.total + " document" + (data.total == 1 ? "" : "s") + " matching ";
    var fields = data.fields.concat(data.attributes);
    var list = $.map(fields, function(f){ return f.value; });
    if (data.text) list.push(data.text);
    var me = this;
    list = $.map(list, function(s) {
      return me.QUOTED.test(s) ? s : '"' + s + '"';
    });
    var last = list.pop();
    
    if (list.length == 0) {
      sentence += last + ".";
    } else if (list.length == 1) { 
      sentence += list[0] + ' and ' + last + ".";
    } else {
      sentence += list.join(', ') + ", and " + last + "."; 
    }
    
    $(this.el).html(sentence); 
    return this;
  }
  
});