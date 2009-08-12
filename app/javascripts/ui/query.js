dc.ui.Query = dc.ui.View.extend({
    
  render : function(count) {
    var data = this.options;
    var sentence = count + " document" + (count == 1 ? "" : "s") + " matching ";
    var list = $.map(data.fields, function(f){ return f.value; });
    if (data.phrase) list = list.concat(data.phrase);
    list = $.map(list, function(s){ return '"' + s + '"'; });
    var last = list.pop();
    if (list.length == 0) return sentence + last + ".";
    if (list.length == 1) return sentence + list[0] + ' and ' + last + ".";
    return sentence + list.join(', ') + ", and " + last + ".";  
  }
  
});