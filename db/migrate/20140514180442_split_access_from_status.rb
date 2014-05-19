class SplitAccessFromStatus < ActiveRecord::Migration
  def change
    reversible do |direction|
      direction.up do 
        add_column :documents,    :status, :integer, :default => 1
        add_column :pages,        :status, :integer, :default => 1
        add_column :entities,     :status, :integer, :default => 1
        add_column :entity_dates, :status, :integer, :default => 1
      end
      direction.down do 
        remove_column :documents,    :status
        remove_column :pages,        :status
        remove_column :entities,     :status
        remove_column :entity_dates, :status
      end
    end
  end
end
