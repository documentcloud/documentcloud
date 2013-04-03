module DC
  # The official list of supported languages

  # should we be using iso15924 script codes?
  #   http://www.unicode.org/iso15924/iso15924-codes.html

  module Language
    SUPPORTED = [
                 'eng', 'spa', 'fra','nor','swe','ara','deu',
                 'chi','zho','jpn','hin','rus'
               ]

    NAMES = {
      'eng' => 'English',
      'spa' => 'Spanish',
      'fra' => 'French',
      'nor' => 'Norwegian',
      'swe' => 'Swedish',
      'ara' => 'Arabic',
      'deu' => 'German',
      'chi' => 'Chinese(Tranditional)',
      'zho' => 'Chinese(Simplified)',
      'jpn' => 'Japanese',
      'hin' => 'Hindu',
      'rus' => 'Russian'
    }

  end

end
