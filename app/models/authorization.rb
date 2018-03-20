class Authorization < ActiveRecord::Base
 
  self.establish_connection( DC::QUACKBOT_DB ) unless Rails.env.testing?
  
  def webhook
    details["incoming_webhook"]["url"]
  end
  
  def notify(message)
    raise ArgumentError unless message.kind_of? String
    RestClient.post(self.webhook, { text: message }.to_json, { content_type: :json })
  end
  
  def name
    details["team_name"]
  end
  
  belongs_to :team
end