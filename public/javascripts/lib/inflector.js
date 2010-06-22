// Naive English transformations on words.
window.Inflector = {

  camelize : function(s) {
    var parts = s.split('-'), len = parts.length;
    if (len == 1) return parts[0];

    var camelized = s.charAt(0) == '-'
      ? parts[0].charAt(0).toUpperCase() + parts[0].substring(1)
      : parts[0];

    for (var i = 1; i < len; i++)
      camelized += parts[i].charAt(0).toUpperCase() + parts[i].substring(1);

    return camelized;
  },

  capitalize : function(s) {
    return s.charAt(0).toUpperCase() + s.substring(1).toLowerCase();
  },

  underscore : function(s) {
    return s.replace(/::/g, '/').replace(/([A-Z]+)([A-Z][a-z])/g,'$1_$2').replace(/([a-z\d])([A-Z])/g,'$1_$2').replace(/-/g,'_').toLowerCase();
  },

  spacify : function(s) {
    return s.replace(/_/g, ' ');
  },

  dasherize : function(s) {
    return s.replace(/_/g,'-');
  },

  singularize : function(s) {
    return s.replace(/s$/, '');
  },

  // Only works for words that pluralize by adding an 's', end in a 'y', or
  // that we've special-cased. Not comprehensive.
  pluralize : function(s, count) {
    if (count == 1) return s;
    if (s == 'person') return 'people';
    if (s.match(/y$/i)) return s.replace(/y$/i, 'ies');
    return s + 's';
  },

  classify : function(s) {
    return this.camelize(this.capitalize(this.dasherize(this.singularize(s))));
  },

  possessivize : function(s) {
    var endsInS = s.charAt(s.length - 1) == 's';
    return s + (endsInS ? "'" : "'s");
  },

  truncate : function(s, length, truncation) {
    length = length || 30;
    truncation = _.isUndefined(truncation) ? '...' : truncation;
    return s.length > length ? s.slice(0, length - truncation.length) + truncation : s;
  },

  commify : function(list, options) {
    var words = [];
    _.each(list, function(word, i) {
      if (options.quote) word = '"' + word + '"';
      words.push(word);
      var end = i == list.length - 1 ? '' :
               (i == list.length - 2) && options.conjunction ? ', ' + options.conjunction + ' ' :
               ', ';
      words.push(end);
    });
    return words.join('');
  }

};