module DC
  # The official list of supported languages

  # Needs to be kept in sync with JS version in
  # public/javascripts/model/language.js
  module Language
    NAMES = {
      'ara' => 'Arabic',
      'zho' => 'Chinese (Simplified)',
      'tra' => 'Chinese (Traditional)', # this is not a real ISO-639-2 code, see note below.
      'hrv' => 'Croatian',
      'dan' => 'Danish',
      'nld' => 'Dutch',
      'eng' => 'English',
      'fra' => 'French',
      'deu' => 'German',
      'heb' => 'Hebrew',
      'hun' => 'Hungarian',
      'ind' => 'Indonesian',
      'ita' => 'Italian',
      'jpn' => 'Japanese',
      'kor' => 'Korean',
      'nor' => 'Norwegian',
      'por' => 'Portuguese',
      'ron' => 'Romanian',
      'rus' => 'Russian',
      'spa' => 'Spanish',
      'swe' => 'Swedish',
      'ukr' => 'Ukrainian'
    }

    SUPPORTED = NAMES.keys
    DEFAULT = 'eng'

    USER = ['dan','eng','fra','rus','spa','ukr']

    # For user facing purposes, documents are considered to have only a language.
    # In reality documents possess two distinct properties a language
    # and a written script. The former can be represented by ISO-639-2
    # language codes and the latter by ISO-15924 script codes.
    #
    # In almost all cases the script of a document can be inferred based
    # on its language (Ukrainian language documents are all written using Cyrillic)
    # with the exception of Chinese which for political and historical reasons
    # possesses two written scripts, traditional and simplified.
    #
    # The Tesseract OCR system requires knowing both language and script in order
    # to be able to correctly process documents, and consequently has two separate
    # langauge packages for Chinese, 'chi-tra' and 'chi-sim'.  All other language
    # packs are identical to their ISO-639-2 code.
    def self.ocr_name(code)
      if code == 'tra'
        'chi_tra'
      elsif code == 'zho'
        'chi_sim'
      else
        code
      end
    end

  end

end
