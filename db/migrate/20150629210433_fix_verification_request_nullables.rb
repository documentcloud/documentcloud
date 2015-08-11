class FixVerificationRequestNullables < ActiveRecord::Migration
  def up
    change_column_null :verification_requests, :signup_key, true
    change_column_null :verification_requests, :country,    false
  end
  def down
    change_column_null :verification_requests, :signup_key, false
    change_column_null :verification_requests, :country,    true
  end
end
