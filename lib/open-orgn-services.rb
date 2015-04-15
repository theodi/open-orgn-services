class Hash
  def compact
    delete_if { |k, v| !v }
  end
end

require 'resque'
require 'resque/scheduler'

# Configure CapsuleCRM connection
require 'capsulecrm'
CapsuleCRM.account_name = ENV['CAPSULECRM_ACCOUNT_NAME']
CapsuleCRM.api_token = ENV['CAPSULECRM_API_TOKEN']
CapsuleCRM.initialize!

require 'xeroizer'
require 'pony'

require 'helpers/membership_helper'

require 'eventbrite-client'
require 'eventbrite/event_monitor'
require 'eventbrite/attendee_monitor'
require 'eventbrite/event_summary_generator'
require 'eventbrite/event_summary_uploader'

require 'chargify/chargify_report_generator'

require 'xero/invoicer'

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
require 'capsulecrm/send_opportunity_reminders'

require 'google_drive/mover'

def environment
  ENV['RACK_ENV'] || 'production'
end
