// Keep this file in sync with lib/dc/language.rb

dc.language = {
  NAMES: {
    'eng': 'English',
    'spa': 'Español/Spanish',
    'fra': 'Français/French',
    'deu': 'Duetch/German',
    'dan': 'Danish',
    'chi': 'Chinese (Traditional)',
    'rus': 'Russian',
    'ukr': 'Ukrainian'
  },
  USER: ['eng','spa','rus','dan','chi','ukr']
};

dc.language.SUPPORTED = _.keys(dc.language.NAMES);
