class AddAccountIdentities < ActiveRecord::Migration
  def self.up
    add_column :accounts, :identities, 'hstore'
    execute "create index index_accounts_on_identites ON accounts USING GIN(identities)"
  end

  def self.down
    remove_column :accounts, :identities
  end

end
