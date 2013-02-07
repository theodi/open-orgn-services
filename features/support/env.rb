$:.unshift File.join( File.dirname(__FILE__), "..", "..", "lib")

require 'simplecov'
require 'simplecov-rcov'
SimpleCov.formatter = SimpleCov::Formatter::RcovFormatter
SimpleCov.start 'rails'

require 'dotenv'
Dotenv.load

require 'vcr'
require 'cucumber/rspec/doubles'

require 'open-orgn-services'

VCR.configure do |c|
  c.filter_sensitive_data("<EVENTBRITE_API_KEY>") { ENV['EVENTBRITE_API_KEY'] }
  c.filter_sensitive_data("<EVENTBRITE_USER_KEY>") { ENV['EVENTBRITE_USER_KEY'] }
  c.filter_sensitive_data("<EVENTBRITE_ORGANISER_ID>") { ENV['EVENTBRITE_ORGANISER_ID'] }
  c.filter_sensitive_data("<XERO_CONSUMER_KEY>") { ENV['XERO_CONSUMER_KEY'] }
  c.filter_sensitive_data("<XERO_CONSUMER_SECRET>") { ENV['XERO_CONSUMER_SECRET'] }
  c.filter_sensitive_data("<XERO_PRIVATE_KEY_PATH>") { ENV['XERO_PRIVATE_KEY_PATH'] }
  c.cassette_library_dir = 'fixtures/vcr_cassettes'
  c.hook_into :webmock # or :fakeweb
end
