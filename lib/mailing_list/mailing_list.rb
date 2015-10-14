require 'gibbon'

class MailingList
  Failure            = Class.new(StandardError)
  SubscribeFailure   = Class.new(Failure)
  UnsubscribeFailure = Class.new(Failure)

  def self.subscribe(params)
    new(params).subscribe
  end

  def self.unsubscribe(params)
    new(params).unsubscribe
  end

  attr_writer :api
  attr_reader :attributes

  def initialize(attributes, list_id = nil)
    @attributes = OpenStruct.new(attributes)
    @list_id    = list_id
  end

  def subscribe
    api.lists.subscribe({
      :id => list_id,
      :email => {
        :email => attributes.email
      },
      :merge_vars => {
        :FNAME      => attributes.contact_first_name,
        :LNAME      => attributes.contact_last_name,
        :LEVEL      => attributes.level,
        :COUNTRY    => attributes.country,
        :TWITTER    => attributes.twitter,
        :JOIN_DATE  => attributes.join_date,
        :ORG_SECTOR => attributes.organization_sector,
        :ORG_NAME   => attributes.organization_name,
        :ORG_SIZE   => attributes.organization_size
      },
      :double_optin => false,
      :update_existing => true
    })
  rescue Gibbon::MailChimpError => e
    raise SubscribeFailure, e.message
  end

  def unsubscribe
    api.lists.unsubscribe(
      :id => list_id,
      :email => {
        :email => attributes.email
      },
      :delete_member => true,
      :send_notify   => false,
      :send_goodbye  => false
    )
  rescue Gibbon::MailChimpError => e
    raise UnsubscribeFailure, e.message
  end

  def api
    @api ||= Gibbon::API.new(api_key)
  end

  def api_key
    @api_key ||= ENV.fetch("MAILING_LIST_API_KEY") do
      raise ArgumentError, "MAILING_LIST_API_KEY is missing"
    end
  end

  def list_id
    @list_id ||= ENV.fetch("MAILING_LIST_LIST_ID") do
      raise ArgumentError, "MAILING_LIST_LIST_ID is missing"
    end
  end
end

