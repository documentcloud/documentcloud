class AddRolesToAccounts < ActiveRecord::Migration
  def self.up
    add_column 'accounts', 'role', :integer
    Account.update_all 'role = 1'
    change_column 'accounts', 'role', :integer, :null => false
  end

  def self.down
    remove_column 'accounts', 'role', :integer
  end
end
