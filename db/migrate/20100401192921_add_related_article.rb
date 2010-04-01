class AddRelatedArticle < ActiveRecord::Migration
  def self.up
    add_column :documents, :related_article, :string
  end

  def self.down
    remove_column :documents, :related_article
  end
end
