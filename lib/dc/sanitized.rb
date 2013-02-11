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
      Sanitize.clean(s, ::DC::Sanitizer.const_get( level.to_s.upcase ) )
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
    SUPER_RELAXED[:attributes].merge!({ 'iframe' => %w[ src srcdoc width height sandbox style ] })
    SUPER_RELAXED[:protocols].merge!({
      'iframe'    => {
        'src'     => ['ftp', 'http', 'https', 'mailto', :relative], 
        'sandbox' => %w[ allow-forms allow-same-origin allow-scripts allow-top-navigation ]
      }
    })
    def Sanitizer.const_missing(sym)
      return Sanitizer::RELAXED
    end
  end

end

# Mix this module into all ActiveRecord models.
ActiveRecord::Base.send :include, DC::Sanitized
