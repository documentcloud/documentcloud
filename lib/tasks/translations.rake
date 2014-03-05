namespace :translations do

  desc "Build download packs of translation strings"
  task :compile => 'translations:download' do
    require 'dc/language'
    DC::Language::SUPPORTED.each do | language_code |
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

      js_namespace = 'DV'
      viewer = Rails.root.join("../document-viewer/public/javascripts/DV/schema/translation.#{language_code}.js")
      File.open( viewer, 'w' ) do | destination_file |
        translation_strings = dictionary['viewer']
        destination_file.write template.result( binding )
      end

    end
  end


  desc "Compile Javascript version of translation strings"
  task :download do

    require "google_drive"
    require 'highline/import'
    require 'yaml'

    username = ask("[translations download] Enter your username:  ") { |q| q.echo = true }
    password = ask("[translations download] Enter your password:  ") { |q| q.echo = "*" }
    SPREADSHEET_KEY = '0AiY4dewFeJcNdGtHM1JRcUh6eW54TW1Peld1TjZoSnc'
    session = GoogleDrive.login( username, password )
    sheets = session.spreadsheet_by_key(SPREADSHEET_KEY).worksheets

    languages = {
      'eng' =>2,
      "spa" =>3,
#      "dan" =>4,
#      "chi" =>7,
      "rus" =>5,
      "ukr" =>6
    }

    sections = {
      "common"    =>1,
      "workspace" =>2,
      "viewer"    =>3
    }


    # The data's stored in hash containing
    #   language -> { section -> { key/value pairs } }
    yaml = Hash.new{ | sections_hash, language_code |
      sections_hash[ language_code] = Hash.new{ | section, section_name |
        section[ section_name ] = {}
      }
    }

    languages.each do | language, col |
      puts "Downloading #{language}"
      language_data = yaml[ language ]

      sections.each do | section, tab |
        tab = sheets[ tab ]
        translations = language_data[section]

        for row in 2..tab.num_rows

          key   = tab[row,1] unless tab[row,1].empty?
          value = tab[row,col]
          STDERR.puts "#{key} has no value set!" if value.empty? && ! translations[key]
          next if value.empty?
          STDERR.puts "#{key} has spaces in it!" if key =~/\s/
          # if there is multiple values for a key, it needs
          # to be stored as an Array
          if translations[ key ]
            if ! translations[key].is_a?(Array)
              translations[key] = [ translations[key] ]
            end
            translations[key].push( value )
            unless ( translations[key].uniq! ).nil?
              STDERR.puts "#{language}:#{section} key: #{key} has value: \"#{value}\" listed more than once"
            end
          else
            translations[key] = value
          end
        end
      end
      ActiveSupport::OrderedHash.new
      File.open("config/locales/#{language}.yml", 'w') do | i18n_file |
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
