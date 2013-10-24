// Keep this file in sync with lib/dc/language.rb

dc.language = {
  NAMES: {
    'eng': 'English',
    'spa': 'Español/Spanish',
    'fra': 'Français/French',
    'deu': 'Duetch/German'
  },
  USER: ['eng','spa']
};

dc.language.SUPPORTED = _.keys(dc.language.NAMES);
