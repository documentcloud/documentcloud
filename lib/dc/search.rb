Dir[File.dirname(__FILE__) + '/search/*.rb'].each {|file| require file }

module DC

  # The Search module takes in a raw query string, processes it, queries
  # our backing stores for the most relevant results, and merges the result
  # sets together according to a strategy of our choosing.
  module Search
    # All Java XML control chars, except:
    # 0x0A (line feed) and 0x0D (carriage return)
    INVALID_SOLR_CHARACTERS = Regexp.new("[\x0-\x09|\x0b|\x0c|\x0e-\x1f]")

    def self.clean_text(text)
      text.gsub(INVALID_SOLR_CHARACTERS, ' ')
    end

    module Matchers
      FIELD         = /("(.+?)"|'(.+?)'|[^'"\s]{2}\S*):\s*("(.+?)"|'(.+?)'|[^'"\s]\S*)/
      QUOTED_VALUE  = /("(.+?)"|'(.+?)')/
      BOOLEAN       = /(\bor\b|\band\b|[!+\-()])/i
    end

    DEFAULT_PER_PAGE  = 10
    MAX_PER_PAGE      = 1000
    DEFAULT_ORDER     = 'score'

  end

end
