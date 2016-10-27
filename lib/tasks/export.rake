require 'csv'

namespace :export do
  desc 'Export Account credentials to csv'
  task :account_credentials, [:start, :batch_size] => [:environment] do |t, args|
    start = args[:start] || 0
    batch_size = args[:batch_size] || 1000

    attributes = %w(id email first_name last_name hashed_password)

    CSV.open('accounts_export.csv','w', headers: true) do |csv|
      csv << attributes

      Account.find_each(start: start, batch_size: batch_size) do |account|
        csv << attributes.map { |attr| account.send(attr) }
      end
    end
  end
end
