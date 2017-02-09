class AddMembershipToCollaboration < ActiveRecord::Migration
  def change
    add_reference :collaborations, :membership, index: true
    add_column :collaborations, :hidden, :boolean, default: false
  end
end
