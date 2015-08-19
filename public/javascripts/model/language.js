// Keep this file in sync with lib/dc/language.rb

dc.language = {
  NAMES: {
    'ara' : 'Arabic',
    'zho' : 'Chinese (Simplified)',
    'tra' : 'Chinese (Traditional)', // this is not a real ISO-639-2 code, see comments on language.rb
    'dan' : 'Danish',
    'eng' : 'English',
    'fra' : 'French',
    'deu' : 'German',
    'hun' : 'Hungarian',
    'ind' : 'Indonesian',
    'ita' : 'Italian',
    'jpn' : 'Japanese',
    'kor' : 'Korean',
    'nld' : 'Dutch',
    'nor' : 'Norwegian',
    'por' : 'Portuguese',
    'spa' : 'Spanish',
    'swe' : 'Swedish',
    'rus' : 'Russian',
    'ukr' : 'Ukrainian'
  },
  USER: ['dan','eng','rus','spa','ukr']
};

// Making an assumption that our user-facing names are unique; seems fair.
dc.language.NAME_KEYS_SORTED_BY_DISPLAY_NAME = (function() {
  var names_inverted = _.invert(dc.language.NAMES);
  var names_sorted   = _.keys(names_inverted).sort();
  return _.map(names_sorted, function(n) { return names_inverted[n]; });
})();

// Order language lists alphabetically by display name.
dc.language.NAMES = (function(){
  var names = {};
  _.each(dc.language.NAME_KEYS_SORTED_BY_DISPLAY_NAME, function(key) {
    names[key] = dc.language.NAMES[key];
  });
  return names;
})();
dc.language.USER = _.intersection(dc.language.NAME_KEYS_SORTED_BY_DISPLAY_NAME, dc.language.USER);

dc.language.SUPPORTED = _.keys(dc.language.NAMES);
