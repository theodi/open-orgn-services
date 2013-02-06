$:.unshift File.join( File.dirname(__FILE__), "..", "..", "lib")

require 'dotenv'
Dotenv.load

require 'vcr'
require 'cucumber/rspec/doubles'

VCR.configure do |c|
  c.filter_sensitive_data("<EVENTBRITE_API_KEY>") { ENV['EVENTBRITE_API_KEY'] }
  c.filter_sensitive_data("<EVENTBRITE_USER_KEY>") { ENV['EVENTBRITE_USER_KEY'] }
  c.cassette_library_dir = 'fixtures/vcr_cassettes'
  c.hook_into :webmock # or :fakeweb
end