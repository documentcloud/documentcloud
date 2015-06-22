class AddInMarketToSignup < ActiveRecord::Migration
  def change
    change_table :verification_requests do |t|
      t.boolean :in_market, :default => false
    end
  end
end
