// The Query is the plain-text, plain-english representation of the thing
// that you just searched for.
dc.ui.Query = dc.View.extend({
  
  className : 'search_query',
    
  render : function(count) {
    var data = this.options;
    var sentence = count + " document" + (count == 1 ? "" : "s") + " matching ";
    var fields = data.fields.concat(data.attributes);
    var list = $.map(fields, function(f){ return f.value; });
    if (data.text) list.push(data.text);
    list = $.map(list, function(s){ return '"' + s + '"'; });
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