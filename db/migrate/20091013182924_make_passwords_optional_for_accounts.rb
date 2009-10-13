class MakePasswordsOptionalForAccounts < ActiveRecord::Migration
  def self.up
    change_column :accounts, :hashed_password, :string, :null => true
  end

  def self.down
    change_column :accounts, :hashed_password, :string, :null => false
  end
end
