require 'net/http'
require 'json'

class HubotMonitor
  
  @queue = :metrics
  
  def self.perform
    # Get JSON list of users
    uri = URI.parse(ENV['HUBOT_USER_LIST'])
    users = JSON.parse(Net::HTTP.get(uri))["users"] rescue []
    # Publish
    Resque.enqueue LeftronicPublisher, :number, ENV['LEFTRONIC_IRC_COUNT'], users.count
  end
  
end