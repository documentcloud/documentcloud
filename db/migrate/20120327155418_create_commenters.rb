class CreateCommenters < ActiveRecord::Migration
  def self.up
    create_table :commenters do |t|
      t.string  "first_name",      :null => false, :limit => 40
      t.string  "last_name",       :null => false, :limit => 40
      t.timestamps
    end
    Commenter.connection.execute <<-EOS
      
    EOS
  end

  def self.down
    drop_table :commenters
  end
end
