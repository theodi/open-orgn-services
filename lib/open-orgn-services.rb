class Hash
  def compact
    delete_if { |k, v| !v }
  end
end

require 'resque'
require 'resque_scheduler'
require 'resque/scheduler'

# Setup redis server
raise "Redis configuration not set" unless ENV['RESQUE_REDIS_HOST'] && ENV['RESQUE_REDIS_PORT']
Resque.redis = Redis.new(
  :host => ENV['RESQUE_REDIS_HOST'], 
  :port => ENV['RESQUE_REDIS_PORT'], 
  :password => (ENV['RESQUE_REDIS_PASSWORD'].nil? || ENV['RESQUE_REDIS_PASSWORD']=='' ? nil : ENV['RESQUE_REDIS_PASSWORD'])
)

# Configure CapsuleCRM connection
require 'capsulecrm'
CapsuleCRM.account_name = ENV['CAPSULECRM_ACCOUNT_NAME']
CapsuleCRM.api_token = ENV['CAPSULECRM_API_TOKEN']
CapsuleCRM.initialize!

require 'xeroizer'
require 'pony'

require 'helpers/metrics_helper'
require 'helpers/membership_helper'

require 'eventbrite-client'
require 'eventbrite/event_monitor'
require 'eventbrite/attendee_monitor'
require 'eventbrite/event_summary_generator'
require 'eventbrite/event_summary_uploader'

require 'xero/invoicer'

require 'github/github_connection'
require 'github/organisation_monitor'
require 'github/issue_monitor'
require 'github/watchers_forks_monitor'
require 'github/pull_request_monitor'
require 'github/outgoing_pull_request_monitor'

require 'leftronic/dashboard_time'
require 'leftronic/leftronic_publisher'
require 'trello/trello_monitor'
require 'trello/quarterly_progress'

require 'hubot/hubot_monitor'

require 'signup/product_helper'
require 'signup/signup_processor'

require 'capsulecrm/capsule_helper'
require 'capsulecrm/partner_enquiry_processor'
require 'capsulecrm/send_signup_to_capsule'
require 'capsulecrm/directory_entry_processor'
require 'capsulecrm/capsule_sync_monitor'
require 'capsulecrm/sync_capsule_data'
require 'capsulecrm/save_membership_id_in_capsule'
require 'capsulecrm/save_membership_details_to_capsule'
require 'capsulecrm/opportunity_age_monitor'
require 'capsulecrm/send_opportunity_reminders'
require 'capsulecrm/membership_count'
require 'capsulecrm/membership_coverage'
require 'capsulecrm/membership_renewals'
require 'capsulecrm/pipeline_metrics'

require 'google_drive/company_dashboard'