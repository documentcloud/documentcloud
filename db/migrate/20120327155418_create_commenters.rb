class CreateCommenters < ActiveRecord::Migration
  def self.up
    create_table :commenters do |t|
      t.string  "first_name",      :limit => 40,  :null => false
      t.string  "last_name",       :limit => 40,  :null => false
      t.string  "email",           :limit => 100
      t.string  "hashed_email"
      t.timestamps
    end
    
    add_column :accounts, :commenter_id, :integer
    
    puts "fissioning commenters from each account"
    Account.all(:order=>'id asc').each do |account|
      print "\r#{account.id}: "
      # use block assignment to allow the primary key to be set
      commenter = Commenter.create do |c|
        c.id = account.id
        c.first_name = account.first_name
        c.last_name = account.last_name
        c.email = account.email
      end
      account.update_attributes(:commenter_id => commenter.id)
      print "Done."
    end
    puts
    Commenter.connection.execute(
      "select setval('commenters_id_seq'::regclass, (select max(id) from commenters group by id order by id desc limit 1));")
  end

  def self.down
    drop_table :commenters
    remove_column :accounts, :commenter_id
  end
end
