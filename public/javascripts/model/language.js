// Keep this file in sync with lib/dc/language.rb

dc.language = {
  NAMES: {
    'zho' : 'Chinese (Simplified)',
    'tra' : 'Chinese (Traditional)', // this is not a real ISO-639-2 code, see note below.
    'dan' : 'Danish',
    'eng' : 'English',
    'fra' : 'French',
    'deu' : 'German',
    'jpn' : 'Japanese',
    'kor' : 'Korean',
    'spa' : 'Spanish',
    'rus' : 'Russian',
    'ukr' : 'Ukrainian'
  },
  USER: ['eng','spa','rus','ukr']
};

dc.language.SUPPORTED = _.keys(dc.language.NAMES);
