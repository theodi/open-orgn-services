require 'curb'

class ApplicationErrors
  
  @queue = :metrics
  
  extend MetricsHelper
  
  def self.unresolved_errors
    response = Curl.get("https://airbrake.io/api/v3/projects?key=#{ENV['AIRBRAKE_API_KEY']}").body_str
    json = JSON.parse(response)
    json["projects"].inject(0) { |total, data| total += data["groupUnresolvedCount"]}
  end
  
  def self.perform
    store_metric('application-errors', Time.now, unresolved_errors)
  end
  
end