class AddAccountIdentities < ActiveRecord::Migration
  def self.up
    add_column :accounts, :identities, 'hstore'
    execute "create index index_accounts_on_identites ON accounts USING GIN(identities)"
    change_column_null :accounts, :first_name, true
    change_column_null :accounts, :last_name,  true
    change_column_null :accounts, :email,      true
  end

  def self.down
    remove_column :accounts, :identities
    change_column_null :accounts, :first_name, false
    change_column_null :accounts, :last_name,  false
    change_column_null :accounts, :email,      false
  end

end
