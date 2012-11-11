class CreateFeaturedReports < ActiveRecord::Migration
  def self.up
    create_table :featured_reports do |t|
      t.string :url, :title, :organization, :null=>false
      t.date :article_date, :null=>false
      t.text :writeup, :null=>false
      t.integer :present_order, :default=>0, :null=>false
      t.timestamps
    end
  end

  def self.down
    drop_table :featured_reports
  end
end
