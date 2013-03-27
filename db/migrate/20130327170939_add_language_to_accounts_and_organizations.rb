class AddLanguageToAccountsAndOrganizations < ActiveRecord::Migration
  def self.up
    add_column :accounts, :language,  :string, :limit => 3
    add_column :organizations, :language,  :string, :limit => 3
  end

  def self.down
    remove_column :accounts, :language
    remove_column :organizations, :language
  end
end
