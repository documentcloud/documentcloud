class RemoveOrganizationIdConstraintOnAccounts < ActiveRecord::Migration
  def self.up
    change_column(:accounts, :organization_id, :integer, :null => true)
  end

  def self.down
    change_column(:accounts, :organization_id, :integer, :null => false)
  end
end
