class AddLanguageToAccountsAndOrganizations < ActiveRecord::Migration
  def self.up
    add_column :accounts,      :language,  :string, :limit => 3, :default => "eng"
    add_column :organizations, :language,  :string, :limit => 3, :default => "eng"
    
    Account.update_all :language=>"eng"
    Organization.update_all :language=>"eng"
  end

  def self.down
    remove_column :accounts, :language
    remove_column :organizations, :language
  end
end
