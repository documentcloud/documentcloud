require 'csv'

namespace :export do
  desc 'Export Account credentials to csv'
  task :account_credentials, [:start, :batch_size] => [:environment] do |_t, args|
    start = args[:start] || 0
    batch_size = args[:batch_size] || 1000

    attributes = %w(id email first_name last_name hashed_password)

    CSV.open('accounts_export.csv', 'w', headers: true) do |csv|
      csv << attributes

      Account.find_each(start: start, batch_size: batch_size) do |account|
        csv << attributes.map { |attr| account.send(attr) }
      end
    end
  end

  desc 'Export Organizations to csv'
  task :organizations, [:start, :batch_size] => [:environment] do |_t, args|
    start = args[:start] || 0
    batch_size = args[:batch_size] || 1000

    attributes = %w(id name slug demo language document_language created_at updated_at)

    CSV.open('organizations_export.csv', 'w', headers: true) do |csv|
      csv << attributes

      Organization.find_each(start: start, batch_size: batch_size) do |organization|
        csv << attributes.map { |attr| organization.send(attr) }
      end
    end
  end

  desc 'Export Memberships to csv'
  task :memberships, [:start, :batch_size] => [:environment] do |_t, args|
    start = args[:start] || 0
    batch_size = args[:batch_size] || 1000

    attributes = %w(id organization_id account_id role default concealed)

    CSV.open('memberships_export.csv', 'w', headers: true) do |csv|
      csv << attributes

      Membership.find_each(start: start, batch_size: batch_size) do |membership|
        csv << attributes.map { |attr| membership.send(attr) }
      end
    end
  end
end

