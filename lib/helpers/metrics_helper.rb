require "httparty"

module MetricsHelper
  
  def store_metric(name, datetime, data)
    
    url = "#{ENV['METRICS_BASE_URL']}metrics/#{name}"
    
    json = {
      name: name,
      time: datetime.xmlschema,
      value: data
    }.to_json
    
    HTTParty.post(url, :body => json, :headers => { 'Content-Type' => 'application/json' } )
        
  end
  
end