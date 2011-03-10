class AddBackNullableProjectTitle < ActiveRecord::Migration
  def self.up
    change_column :projects, :title, :string, :null => true
  end

  def self.down
    # noop.
  end
end
