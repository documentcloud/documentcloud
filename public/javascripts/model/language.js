// Keep this file in sync with lib/dc/language.rb

dc.language = {
  NAMES: {
    'ara' : 'Arabic',
    'zho' : 'Chinese (Simplified)',
    'tra' : 'Chinese (Traditional)', // this is not a real ISO-639-2 code, see comments on language.rb
    'hrv' : 'Croatian',
    'dan' : 'Danish',
    'nld' : 'Dutch',
    'eng' : 'English',
    'fra' : 'French',
    'deu' : 'German',
    'heb' : 'Hebrew',
    'hun' : 'Hungarian',
    'ind' : 'Indonesian',
    'ita' : 'Italian',
    'jpn' : 'Japanese',
    'kor' : 'Korean',
    'nor' : 'Norwegian',
    'por' : 'Portuguese',
    'ron' : 'Romanian',
    'rus' : 'Russian',
    'spa' : 'Spanish',
    'swe' : 'Swedish',
    'ukr' : 'Ukrainian'
  },
  USER: ['dan','eng','fra','rus','spa','ukr']
};

dc.language.SUPPORTED = _.keys(dc.language.NAMES);
