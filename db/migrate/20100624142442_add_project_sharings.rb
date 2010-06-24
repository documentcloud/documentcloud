class AddProjectSharings < ActiveRecord::Migration
  def self.up
    create_table "project_sharings", :force => true do |t|
      t.integer "project_id", :null => false
      t.integer "account_id", :null => false
    end
  end

  def self.down
    drop_table "project_sharings"
  end
end
