class CreateMembership < ActiveRecord::Migration
  def self.up
    create_table "memberships" do |t|
      t.integer "organization_id",  :null => false
      t.integer "account_id",       :null => false
      t.integer "role",             :null => false
      t.boolean "default",          :default => false
    end
  end

  def self.down
    drop_table "memberships"
  end
end
