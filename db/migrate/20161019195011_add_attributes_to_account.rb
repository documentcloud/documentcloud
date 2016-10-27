class AddAttributesToAccount < ActiveRecord::Migration
  def change
    remove_column :accounts, :identities, :string

    add_column :accounts, :provider, :string
    add_column :accounts, :access_token, :string
    add_column :accounts, :uid, :integer
  end
end
