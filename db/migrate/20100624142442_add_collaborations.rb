class AddCollaborations < ActiveRecord::Migration
  def self.up
    create_table "collaborations", :force => true do |t|
      t.integer "project_id", :null => false
      t.integer "account_id", :null => false
    end
  end

  def self.down
    drop_table "collaborations"
  end
end
