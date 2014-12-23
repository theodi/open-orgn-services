source 'https://rubygems.org'

#ruby=ruby-1.9.3
#ruby-gemset=open-orgn-services

gemspec

# These should be grabbed from git, not rubygems, as we have our own fixes
gem 'capsulecrm', github: 'xmacinka/capsulecrm'
gem 'google_drive', github: 'theodi/google-drive-ruby', branch: 'support-ranges'
gem 'eventbrite-client', github: 'theodi/eventbrite-client.rb', branch: 'update-dependencies'

group :development, :test do
  gem 'cucumber'         , '~> 1.2'
  gem 'dotenv'           , '~> 0.5'
  gem 'email_spec'       , '~> 1.5'
  gem 'guard-cucumber'   , '~> 1.3'
  gem 'guard-spork'      , '~> 1.4'
  gem 'pry'              , '~> 0.9'
  gem 'rb-fsevent'       , '~> 0.9'
  gem 'relish'           , '~> 0.6'
  gem 'rspec'            , '~> 2.12'
  gem 'simplecov-rcov'   , '~> 0.2'
  gem 'timecop'          , '~> 0.5'
  gem 'vcr'              , '~> 2.9' 
  gem 'webmock'          , '1.9.3'
  gem 'mock_redis'
end
