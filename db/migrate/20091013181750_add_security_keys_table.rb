class AddSecurityKeysTable < ActiveRecord::Migration
  def self.up
    create_table "security_keys", :force => true do |t|
      t.string  "securable_type"
      t.integer "securable_id",   :null => false
      t.string  "key"
    end
  end

  def self.down
    drop_table "security_keys"
  end
end
