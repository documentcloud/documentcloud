dc.ui.Query = dc.View.extend({
  
  className : 'search_query',
    
  render : function(count) {
    var data = this.options;
    var sentence = count + " document" + (count == 1 ? "" : "s") + " matching ";
    var list = $.map(data.fields, function(f){ return f.value; });
    if (data.phrase) list.push(data.phrase);
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