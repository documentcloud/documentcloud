module DC

  module I18n

    STRINGS = {}

    DC::Language::SUPPORTED.each do | code |
      path = Rails.root.join('config','locales', "#{code}.yml" )
      STRINGS[ code ] = YAML.load_file( path )['workspace'] if path.exist?
    end

    ENGLISH = STRINGS['eng'] # our fallback

    def self.plural_index( language, num )
      return num && num > 1 ? 1 : 0;
    end

    def self.lookup( account, key, *args )
      language = account ? account.language : 'eng'

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

  def DC.t( account, key, *args )
    DC::I18n.lookup( account, key, args )
  end

end
