source 'https://rubygems.org'

gemspec

gem 'eventbrite-client'
gem 'resque'
gem 'resque-scheduler', :require => 'resque_scheduler'
# This should be grabbed from git, not rubygems, as we have our own fixes
gem 'xeroizer', :git => 'https://github.com/theodi/xeroizer.git'
gem 'github_api'
gem 'leftronicapi'
gem 'ruby-trello'
gem 'jenkins-remote-api'

group :development, :test do
  gem 'cucumber'
  gem 'rspec'
  gem 'vcr'
  gem 'webmock'
  gem 'dotenv'
  gem 'simplecov'
  gem 'simplecov-rcov'
  gem 'guard-cucumber'
  gem 'guard-spork'
  gem 'rb-fsevent', '~> 0.9.1'
  gem 'relish'
  gem 'timecop'
end

gem 'thin'
gem 'foreman'