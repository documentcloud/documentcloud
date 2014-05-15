class SplitAccessFromStatus < ActiveRecord::Migration
  def change
    reversible do |direction|
      direction.up   { add_column  :documents, :status, :integer, :default => 1 }
      direction.down { remove_column :documents, :status }
    end
  end
end
