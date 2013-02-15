require 'dotenv'
Dotenv.load

class Hash
  def compact
    delete_if { |k, v| !v }
  end
end

require 'resque'
require 'xeroizer'

require 'eventbrite-client'
require 'eventbrite/event_lister'
require 'eventbrite/attendee_lister'
require 'eventbrite/attendee_invoicer'
require 'eventbrite/event_summary_generator'
require 'eventbrite/event_summary_uploader'

require 'github/github_monitor'
require 'jenkins/build_status_monitor'
require 'leftronic/dashboard_time'
require 'leftronic/leftronic_publisher'
require 'trello/trello_monitor'