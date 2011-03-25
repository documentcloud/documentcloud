dc.ui.Autocomplete = Backbone.View.extend({
  
  tagName   : 'ul',
  className : 'autocomplete',
  
  initialize : function() {
    _.bindAll(this, 'showValues', 'checkKeypress');
    this.attachToInput();
  },
  
  attachToInput : function() {
    this.options.input.bind('keypress', this.checkKeypress);
    this.keypressCallback = _.debounce(_.bind(function() {
      this.options.checkCallback(this.options.input.val(), this.showValues);
    }, this), 150);
  },
  
  checkKeypress : function(e) {
    if (e.keyCode == 13) {
      this.options.successCallback(this.options.input.val());
    } else {
      this.keypressCallback();
    }
  },
  
  showValues : function(values, partial) {
    var selectedValues = this.selectValues(values, partial);
    console.log(['showValues', selectedValues, partial]);
    var $values = this.render(selectedValues, partial);
  },
  
  selectValues : function(values, partial) {
    var values = _.select(values, function(value) {
      var modValue   = value.toLowerCase();
      var modPartial = partial.toLowerCase();

      if (modValue.indexOf(modPartial) != -1) return true;
    });
    values = _.sortBy(values, function(value) {
      var modValue   = value.toLowerCase();
      var modPartial = partial.toLowerCase();
      
      return modValue.indexOf(modPartial);
    });
    return values;
  },
  
  render : function(selectedValues, partial) {
    $(this.el).html(JST['workspace/autocomplete']({
      values  : selectedValues,
      partial : partial
    }));
    console.log(['render', $(this.el)]);
    this.options.input.after(this.el);
    $(this.el).align(this.options.input, 'bottom left', {'bottom': 4});
  }
  
});
  