require 'gibbon'

class MailingList
  SubscribeFailure   = Class.new(StandardError)
  UnsubscribeFailure = Class.new(StandardError)

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
        :FNAME => "",
        :LNAME => "",
        :LEVEL => attributes.level
      },
      :double_optin => false
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
    @api ||= Gibbon::API.new
  end

  def list_id
    @list_id ||= ENV.fetch("MAILCHIMP_LIST_ID")
  end
end

