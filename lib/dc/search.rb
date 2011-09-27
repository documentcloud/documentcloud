module DC

  # The Search module takes in a raw query string, processes it, queries
  # our backing stores for the most relevant results, and merges the result
  # sets together according to a strategy of our choosing.
  module Search

    module Matchers
      FIELD         = /("(.+?)"|'(.+?)'|[^'"\s]{2}\S*):\s*("(.+?)"|'(.+?)'|[^'"\s]\S*)/
      QUOTED_VALUE  = /("(.+?)"|'(.+?)')/
      BOOLEAN       = /(or|and|[*!+\-()])/i
    end

    DEFAULT_PER_PAGE  = 10
    MAX_PER_PAGE      = 1000
    DEFAULT_ORDER     = 'score'

  end

end
