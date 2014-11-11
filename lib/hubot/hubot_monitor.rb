require 'net/http'
require 'json'

class HubotMonitor
  
  @queue = :metrics
  
  extend MetricsHelper
  
  def self.perform
    # Get JSON list of users
    uri = URI.parse(ENV['HUBOT_USER_LIST'])
    users = JSON.parse(Net::HTTP.get(uri))["users"] rescue []
    # Push into metrics
    store_metric "irc-theodi-users", DateTime.now, users.count
  end
  
end