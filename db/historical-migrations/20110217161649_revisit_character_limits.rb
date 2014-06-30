class RevisitCharacterLimits < ActiveRecord::Migration
  def self.up
    change_column :sections,  :title,  :text,    :null => false
    change_column :documents, :title,  :string,  :null => false, :limit => 1000
    change_column :documents, :source, :string,                  :limit => 1000
  end

  def self.down
    change_column :sections,  :title,  :string,  :null => false
    change_column :documents, :title,  :string,  :null => false
    change_column :documents, :source, :string
  end
end
