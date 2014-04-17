require 'csv'

namespace :import do

  desc "Create/Modify an organization with accounts from CSV file."
  task :accounts, [ :slug, :csv] => :environment do | t,args |

    Organization.transaction do

      begin

        organization = Organization.find_by_slug( args[:slug] )
        raise "Organization for slug: #{args[:slug]} was not found!" unless organization

        puts "Account ID,First Name,Last Name,Email,Password"
        CSV.foreach( args[:csv] ) do | fname, lname, email, is_admin |


          email += "@documentcloud.org" unless email.include?('@')

          account = Account.new({ :email             => email.strip,
                                  :first_name        => fname.strip,
                                  :last_name         => lname.strip,
                                  :language          => organization.language,
                                  :document_language => organization.document_language })

          pw = generate_password
          account.password = pw
          account.save!

          organization.add_member( account, is_admin ? Account::ADMINISTRATOR : Account::CONTRIBUTOR )

          puts [ account.id, account.first_name, account.last_name, account.email, pw ].join(",")
        end

      rescue Exception=>e
        STDERR.puts e
        raise ActiveRecord::Rollback
      end

    end

  end

end

# generate an password with using commonly confused characters
def generate_password( len = 6 )
  charset = %w{ 2 3 4 6 7 9 A C D E F G H J K M N P Q R T V W X Y Z a c d e g h j k m n p q r v w x y z }
  (0...len).map{ charset.to_a[rand(charset.size)] }.join
end
