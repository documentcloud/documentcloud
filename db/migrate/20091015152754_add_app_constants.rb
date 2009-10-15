class AddAppConstants < ActiveRecord::Migration
  def self.up
    create_table "app_constants", :force => true do |t|
      t.string  "key"
      t.string  "value"
    end
  end

  def self.down
    drop_table "app_constants" 
  end
end
