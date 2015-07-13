class AddPositionToVerificationRequests < ActiveRecord::Migration
  def change
    change_table :verification_requests do |t|
      t.string :requester_position
    end
  end
end
