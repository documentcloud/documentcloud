dc.ui.Query = function(data) {
  this.data = data;
};

dc.ui.Query.prototype = {
    
  render : function(count) {
    var sentence = count + " document" + (count > 1 ? "s" : "") + " matching ";
    var list = $.map(this.data.fields, function(f){ return f.value; });
    if (this.data.phrase) list = list.concat(this.data.phrase);
    list = $.map(list, function(s){ return '"' + s + '"'; });
    var last = list.pop();
    if (list.length == 0) return sentence + last + ".";
    if (list.length == 1) return sentence + list[0] + ' and ' + last + ".";
    return sentence + list.join(', ') + ", and " + last + ".";  
  }
  
};