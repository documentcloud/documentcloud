module DC

  module Sanitized

    # Strip all HTML from a string.
    def strip(s)
      Sanitize.clean(s)
    end

    # Clean unsafe HTML from a string,
    def sanitize(s)
      Sanitize.clean(s, Sanitize::Config::RELAXED)
    end

    # Class methods to mix in.
    module ClassMethods

      # Text attributes are stripped of HTML before they are saved.
      def text_attrs(*attrs)
        attrs.each do |att|
          class_eval "def #{att}=(val); self[:#{att}] = strip(val); end"
        end
      end

      # HTML attributes are sanitized of malicious HTML before being saved.
      def html_attrs(*attrs)
        attrs.each do |att|
          class_eval "def #{att}=(val); self[:#{att}] = sanitize(val); end"
        end
      end

    end

    # When this module is included, also add the class methods.
    def self.included(klass)
      klass.extend ClassMethods
    end

  end

end

# Mix this module into all ActiveRecord models.
ActiveRecord::Base.send :include, DC::Sanitized