$:.unshift File.join( File.dirname(__FILE__), "..", "..", "lib")

require 'simplecov'
require 'simplecov-rcov'
SimpleCov.formatter = SimpleCov::Formatter::RcovFormatter
SimpleCov.start 'rails'

require 'dotenv'

require 'spork'
#uncomment the following line to use spork with the debugger
#require 'spork/ext/ruby-debug'

require 'vcr'
require 'cucumber/rspec/doubles'

Spork.prefork do
  Dotenv.load
end

Spork.each_run do
  require 'open-orgn-services'

  VCR.configure do |c|
    # Automatically filter all secure details that are stored in the environment
    ignore_env = %w{SHLVL RUNLEVEL GUARD_NOTIFY DRB}
    (ENV.keys-ignore_env).select{|x| x =~ /\A[A-Z_]*\Z/}.each do |key|
      c.filter_sensitive_data("<#{key}>") { ENV[key] }
    end
    c.default_cassette_options = { :record => :new_episodes }
    c.cassette_library_dir = 'fixtures/vcr_cassettes'
    c.hook_into :webmock
  end
  
  VCR.cucumber_tags do |t|
    t.tag '@vcr', use_scenario_name: true 
  end
  
end