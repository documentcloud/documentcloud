module DC
  # The official list of supported languages

  # should we be using iso15924 script codes?
  #   http://www.unicode.org/iso15924/iso15924-codes.html

  # Needs to be kept in sync with JS version in
  # lib/dc/language.js
  module Language
    NAMES = {
      'eng' => 'English',
      'spa' => 'Spanish',
      'fra' => 'French',
      'deu' => 'German',
      'dan'=> 'Danish',
      'rus'=> 'Russian',
      'ukr'=> 'Ukrainian'
    }

    SUPPORTED = NAMES.keys
    DEFAULT = 'eng'
    
    USER = ['spa','eng','rus','ukr']
  end

end
