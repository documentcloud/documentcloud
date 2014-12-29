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
    'ita' : 'Italian',
    'jpn' : 'Japanese',
    'kor' : 'Korean',
    'por' : 'Portuguese',
    'spa' : 'Spanish',
    'rus' : 'Russian',
    'ukr' : 'Ukrainian'
  },
  USER: ['eng','spa','rus','ukr']
};

dc.language.SUPPORTED = _.keys(dc.language.NAMES);
