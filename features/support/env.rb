$:.unshift File.join( File.dirname(__FILE__), "..", "..", "lib")

require 'simplecov'
require 'simplecov-rcov'
SimpleCov.formatter = SimpleCov::Formatter::RcovFormatter
SimpleCov.start 'rails'

require 'vcr'
require 'cucumber/rspec/doubles'

require 'open-orgn-services'

VCR.configure do |c|
  (ENV.keys-['SHLVL']).select{|x| x =~ /\A[A-Z_]*\Z/}.each do |key|
    c.filter_sensitive_data("<#{key}>") { ENV[key] }
  end
  c.cassette_library_dir = 'fixtures/vcr_cassettes'
  c.hook_into :webmock # or :fakeweb
end