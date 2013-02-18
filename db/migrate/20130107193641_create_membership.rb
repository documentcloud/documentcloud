class CreateMembership < ActiveRecord::Migration
  def self.up
    create_table "memberships" do |t|
      t.integer "organization_id",  :null => false
      t.integer "account_id",       :null => false
      t.integer "role",             :null => false
      t.boolean "default",          :default => false
      t.boolean "concealed",        :default => false
    end
    
    add_index :memberships, :account_id
    add_index :memberships, :organization_id
    
    Account.all.each do |account|
      puts "#{account.id}\e[1A"
      m = account.memberships.new(:role=>account.attributes['role'], :organization_id => account.attributes['organization_id'], :default => true)
      raise StandardError, "Unable to save membership for #{account.email}" unless m.save
    end
  end

  def self.down
    remove_index :memberships, :account_id
    remove_index :memberships, :organization_id
    drop_table "memberships"
  end
end
