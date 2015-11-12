class AddPageNumberToRemoteUrls < ActiveRecord::Migration
  def connection
    RemoteUrl.connection
  end

  def change
    add_column :remote_urls, :page_number, :integer, :null => true
  end
end
