class AddAspectRatioToPages < ActiveRecord::Migration
  def change
    add_column :pages, :aspect_ratio, :float, null: true
  end
end
