module DC

  module I18n

    STRINGS = {}

    ['en','es'].each do | code |
      STRINGS[ code ] = YAML.load_file( Rails.root.join('config','locales', "#{code}.yml" ) )[code]
    end

    ENGLISH = STRINGS['en'] # our fallback

    def self.plural_index( language, num )
      return num && num > 1 ? 1 : 0;
    end

    def self.lookup( language, key, *args )
      lookup = STRINGS[ language ] || ENGLISH

      if ! translation = lookup[key]
        Rails.logger.warn "I18N key #{key} was not found in language #{language}"
        if ! translation = ENGLISH[key]
          Rails.logger.warn "I18N key #{key} was not found in fallback english lookup"
          return key
        end
      end

      if args.empty?
        return translation
      else
        if translation.is_a?(Array)  # plural lookup
          translation = translation[ self.plural_index( language, args[0] ) ]
        end
        return sprintf( translation, *args )
      end
    end

  end
end
