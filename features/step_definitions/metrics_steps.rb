Then(/^the following data should be stored in the "(.*?)" metric$/) do |metric, value|
  json = JSON.parse("{\"name\":\"#{metric}\",\"time\":\"#{DateTime.now.xmlschema}\",\"value\":#{value}}").to_json
  auth = {:username => ENV['METRICS_API_USERNAME'], :password => ENV['METRICS_API_PASSWORD']}
  HTTParty.should_receive(:post).
      with("#{ENV['METRICS_API_BASE_URL']}metrics/#{metric}", :body => json, :headers => { 'Content-Type' => 'application/json' },
          :basic_auth => auth).
      once
  HTTParty.should_receive(:post).any_number_of_times
end

