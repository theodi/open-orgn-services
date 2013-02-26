class Hash
  def compact
    delete_if { |k, v| !v }
  end
end

require 'resque'

# Setup redis server
raise "ENV['RESQUE_REDIS_SERVER'] not set" unless ENV['RESQUE_REDIS_SERVER']
Resque.redis = ENV['RESQUE_REDIS_SERVER']

require 'xeroizer'

require 'eventbrite-client'
require 'eventbrite/event_monitor'
require 'eventbrite/attendee_monitor'
require 'eventbrite/attendee_invoicer'
require 'eventbrite/event_summary_generator'
require 'eventbrite/event_summary_uploader'

require 'github/github_monitor'
require 'jenkins/build_status_monitor'
require 'leftronic/dashboard_time'
require 'leftronic/leftronic_publisher'
require 'trello/trello_monitor'
require 'hubot/hubot_monitor'

require 'signup/user'
require 'signup/signup_processor'