class Team < ActiveRecord::Base
 
  self.establish_connection( DC::QUACKBOT_DB ) unless Rails.env.testing?
  
  has_many :authorizations
  
  def verify(account)
    self.verified_by = account.id
    self.verified = true
    if self.save
      latest_authorization.notify("Thanks! DocumentCloud just approved me for your Slack!")
    end
  end
  
  def latest_authorization
    authorizations.order('created_at desc').first
  end
end
