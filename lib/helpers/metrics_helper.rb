require "httparty"

METRICS_BASE_URL = 'http://metrics.theodi.org'

module MetricsHelper
  
  def store_metric(name, date, data)
    
    url = "#{METRICS_BASE_URL}/metrics/#{name}"
    
    json = {
      name: name,
      date: date.xmlschema,
      value: data
    }.to_json
    
    HTTParty.post(url, :body => json, :headers => { 'Content-Type' => 'application/json' } )
        
  end
  
end