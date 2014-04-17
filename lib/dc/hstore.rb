module DC

  # utility methods for using HSTORE columns in database.
  # Taken from the activerecord-postgres-hstore gem
  # https://github.com/softa/activerecord-postgres-hstore/blob/master/lib/activerecord-postgres-hstore/hash.rb
  module Hstore
    ESCAPED = /[,\s=>\\]/


    # Escapes values such that they will work in an hstore string
    def self.escape(str)
      if str.nil?
        return 'NULL'
      end

      str = str.to_s.dup
      # backslash is an escape character for strings, and an escape character for gsub, so you need 6 backslashes to get 2 in the output.
      # see http://stackoverflow.com/questions/1542214/weird-backslash-substitution-in-ruby for the gory details
      str.gsub!(/\\/, '\\\\\\')
      # escape backslashes before injecting more backslashes
      str.gsub!(/"/, '\"')

      if str =~ ESCAPED or str.empty?
        str = '"%s"' % str
      end

      return str
    end

    # Generates an hstore string format. This is the format used
    # to insert or update stuff in the database.
    def self.quote( hash )
      hash.inject({}) do | ret, kv |
        ret[ escape(kv.first) ] = escape(kv.last)
        ret
      end
    end

    def self.to_sql(hash)
      return '' if hash.blank?
      hash.map do |idx, val|
        "%s=>%s" % [escape(idx), escape(val)]
      end * ","
    end

    def self.from_sql( str )
      str.blank? ? {} : Hash[ str.scan(/"(.*?[^\\]|)"=>"(.*?[^\\]|)"/) ]
    end

  end

end
