class RemoveRoleAndOrganizationFromAccounts < ActiveRecord::Migration
  def self.up
    remove_index :accounts, 'organization_id'
    
    remove_column :accounts, 'role'
    remove_column :accounts, 'organization_id'
  end

  def self.down
    add_column 'accounts', 'role',            :integer
    add_column 'accounts', 'organization_id', :integer
    Account.all.each do |account|
      default_membership = account.memberships.first(:conditions=>{:default=>true})
      account.update_attributes(:organization_id => default_membership.organization_id, :role => default_membership.role)
    end
    change_column 'accounts', 'role',            :integer, :null => false
    change_column 'accounts', 'organization_id', :integer, :null => false
  end
end
