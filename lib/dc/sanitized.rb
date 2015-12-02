module DC

  # This module provides HTML stripping and sanitization to all our models,
  # in a fashion that is (hopefully) easy to configure.
  module Sanitized

    # Strip all HTML from a string.
    def strip(s)
      Sanitize.clean(s)
    end

    # Clean unsafe HTML from a string.
    def sanitize(s, level=:relaxed)
      Sanitize.clean(s, DC::Sanitizer::LEVELS[ level ] )
    end
    
    def sluggify(string)
      slugged = string
      slugged.gsub!(/[^\p{Letter}\p{Number}]/, ' ') # All non-word characters become spaces.
      slugged.squeeze!(' ')     # Squeeze out runs of spaces.
      slugged.strip!            # Strip surrounding whitespace
      # Truncate to the nearest space.
      if slugged.length > 50
        words = slugged[0...50].split(/\s|_|-/)
        slugged = words.length > 1 ? words[0, words.length - 1].join(' ') : words.first
      end
      slugged.gsub!(' ', '-')   # Dasherize spaces.
      slugged
    end

    # Class methods to mix in.
    module ClassMethods

      # Text attributes are stripped of HTML before they are saved.
      def text_attr(*attrs)
        attrs.each do |att|
          class_eval "def #{att}=(val); self[:#{att}] = strip(val); end"
        end
      end
      
      # 
      def styleable_attr(*attrs)
        attrs.each do |att|
          class_eval "def #{att}=(val); self[:#{att}] = sanitize(val); end"
        end
      end

      # HTML attributes are sanitized of malicious HTML before being saved.
      # Accepts a list of attribute names, with optional level specifiied at end.
      # If not specified, the level defaults to :super_relaxed
      #    html_attr :sanitized_attr, :another_sanitized_attr, :level=>:basic
      def html_attr(*attrs)
        options = attrs.extract_options!.reverse_merge({
                                                         :level => :super_relaxed
                                                       })
        attrs.each do |att|
          class_eval "def #{att}=(val); self[:#{att}] = sanitize(val, :#{options[:level]}); end"
        end
      end

    end

    # When this module is included, also add the class methods.
    def self.included(klass)
      klass.extend ClassMethods
    end

  end
  
  module Sanitizer
    RESTRICTED    = Sanitize::Config::RESTRICTED.dup
    BASIC         = Sanitize::Config::BASIC.dup
    RELAXED       = Sanitize::Config::RELAXED.dup
    SUPER_RELAXED = Sanitize::Config::RELAXED.dup
    SUPER_RELAXED[:elements] += %w[ iframe ]
    SUPER_RELAXED[:attributes].merge!({ 'iframe' => %w[ src srcdoc width height sandbox ] })
    SUPER_RELAXED[:protocols].merge!({
      'iframe'    => {
        'src'     => ['ftp', 'http', 'https', 'mailto', :relative], 
        'sandbox' => %w[ allow-forms allow-same-origin allow-scripts allow-top-navigation ]
      }
    })
    LEVELS = {
      :restricted    => RESTRICTED,
      :basic         => BASIC,
      :relaxed       => RELAXED,
      :super_relaxed => SUPER_RELAXED
    }

  end



end

# Mix this module into all ActiveRecord models.
ActiveRecord::Base.send :include, DC::Sanitized
