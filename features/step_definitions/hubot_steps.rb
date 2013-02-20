Given /^there are (#{INTEGER}) people in IRC$/ do |num|
  uri = URI.parse(ENV['HUBOT_USER_LIST'])
  JSON.parse(Net::HTTP.get(uri))["users"].count.should == num
end

When /^the hubot monitor runs$/ do
  HubotMonitor.perform
end
