// Snagged from Prototype
window.Inflector = {
  
  camelize: function(s) {
    var parts = s.split('-'), len = parts.length;
    if (len == 1) return parts[0];

    var camelized = s.charAt(0) == '-'
      ? parts[0].charAt(0).toUpperCase() + parts[0].substring(1)
      : parts[0];

    for (var i = 1; i < len; i++)
      camelized += parts[i].charAt(0).toUpperCase() + parts[i].substring(1);

    return camelized;
  },

  capitalize: function(s) {
    return s.charAt(0).toUpperCase() + s.substring(1).toLowerCase();
  },

  underscore: function(s) {
    return s.replace(/::/g, '/').replace(/([A-Z]+)([A-Z][a-z])/g,'$1_$2').replace(/([a-z\d])([A-Z])/g,'$1_$2').replace(/-/g,'_').toLowerCase();
  },

  dasherize: function(s) {
    return s.replace(/_/g,'-');
  }
  
};