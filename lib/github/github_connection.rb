require 'github_api'

module Github

  def self.connection
    @@github ||= Github.new oauth_token: ENV['GITHUB_OAUTH_TOKEN']
  end
    
end