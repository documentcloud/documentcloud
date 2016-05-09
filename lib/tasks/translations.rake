namespace :translations do

  desc "Build download packs of translation strings"
  task :compile => 'translations:download' do
    require 'dc/language'
    DC::Language::USER.each do | language_code |
      path =  Rails.root.join('config','locales', "#{language_code}.yml" )
      next unless path.exist?
      dictionary = YAML.load_file( path )
      template = ERB.new( File.read( Rails.root.join("app/views/jst/translations/#{language_code}.js.erb") ) )

      js_namespace = 'WS'
      workspace = Rails.root.join('public','javascripts','translations', "#{language_code}.js")
      File.open( workspace, 'w' ) do | destination_file |
        translation_strings = dictionary['workspace']
        destination_file.write template.result( binding )
      end

      # js_namespace = 'DV'
      # viewer = Rails.root.join("../document-viewer/public/javascripts/DV/schema/translation.#{language_code}.js")
      # File.open( viewer, 'w' ) do | destination_file |
      #   translation_strings = dictionary['viewer']
      #   destination_file.write template.result( binding )
      # end

    end
  end

  desc "Compile Javascript version of translation strings"
  task :download do

    require "google_drive"
    require 'highline/import'
    require 'yaml'

    CLIENT_ID       = DC::SECRETS['google']['drive']['key']
    CLIENT_SECRET   = DC::SECRETS['google']['drive']['secret']
    SPREADSHEET_KEY = '1niK_gv0wsFPF2l3WvXprb6JVs6fZzFSERhTtrk42Ys4'

    client = Google::APIClient.new(
      :application_name => 'DocumentCloud Translations',
      :application_version => '0.1',
    )
    auth = client.authorization
    auth.client_id = CLIENT_ID
    auth.client_secret = CLIENT_SECRET
    auth.scope = [
      "https://www.googleapis.com/auth/drive",
      "https://spreadsheets.google.com/feeds/"
    ]
    auth.redirect_uri = "https://dev.dcloud.org/util/google_oauth_code"
    puts "For us to download translations, you have to:\n\n"
    puts "1. Go to a special Google authorization page\n"
    puts "2. Log in  if not already logged in\n"
    puts "3. Grant us access permissions\n"
    puts "4. Copy an authorization code\n"
    puts "5. Bring it back here\n\n"
    puts "Ready? Open this long URL in a browser: #{auth.authorization_uri}\n"
    auth.code = ask("Enter the provided authorization code: ") { |q| q.echo = true }
    auth.fetch_access_token!
    access_token = auth.access_token
    session = GoogleDrive.login_with_oauth(access_token)

    sheets = session.spreadsheet_by_key(SPREADSHEET_KEY).worksheets

    languages = {
      "eng" => "English",
      "fra" => "French",
      "spa" => "Spanish",
      "dan" => "Danish",
      "rus" => "Russian",
      "ukr" => "Ukrainian",
      # "chi" => "Mandarin (Traditional)",
    }

    translation_sheets = {
      "common"    => 1,
      "workspace" => 2,
      "viewer"    => 3,
    }

    # The data's stored in hash containing
    # lang -> { sheet -> { key: value } }
    yaml = Hash.new{ | sheets_hash, lang_code |
      sheets_hash[ lang_code ] = Hash.new{ | sheet, sheet_name |
        sheet[ sheet_name ] = {}
      }
    }

    languages.each do | lang, lang_label |
      puts "DOWNLOADING: #{lang_label}..."
      language_data = yaml[ lang ]

      translation_sheets.each do | sheet_label, sheet_position |
        sheet        = sheets[ sheet_position ]
        translations = language_data[sheet_label]

        for col in 2..sheet.num_cols
            lang_col = col if sheet[2,col] == lang
        end

        for row in 3..sheet.num_rows
          key   = sheet[row,1] unless sheet[row,1].empty?
          value = sheet[row,lang_col]
          STDERR.puts "Missing value for `#{lang}:#{sheet_label}:#{key}`" if value.empty? && !translations[key]
          next if value.empty?
          STDERR.puts "Whitespace found in `#{lang}:#{sheet_label}:#{key}`" if key =~/\s/
          # if there is multiple values for a key, it needs
          # to be stored as an Array
          if translations[ key ]
            if !translations[key].is_a?(Array)
              translations[key] = [ translations[key] ]
            end
            translations[key].push( value )
            unless ( translations[key].uniq! ).nil?
              STDERR.puts "Duplicate value for `#{lang}:#{sheet_label}:#{key}`: `#{value}`"
            end
          else
            translations[key] = value
          end
        end
      end

      ActiveSupport::OrderedHash.new
      File.open("config/locales/#{lang}.yml", 'w') do | i18n_file |
        common = language_data['common']
        combined = ActiveSupport::OrderedHash.new
        language_data.sort.each do | section_name, section_data |
          next if section_name == 'common'
          sorted = ActiveSupport::OrderedHash.new
          translation = section_data.merge( common )
          translation.keys.sort.each do | key |
            sorted[key] = translation[key]
          end
          combined[section_name]=sorted
        end
        i18n_file.write( combined.to_yaml )
      end

    end
  end
end
