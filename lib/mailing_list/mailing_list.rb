require 'gibbon'

class MailingList
  def self.subscribe(email)
    new(email).subscribe
  end

  def self.unsubscribe(email)
    new(email).unsubscribe
  end

  attr_writer :api
  attr_reader :email

  def initialize(email, list_id = nil)
    @email   = email
    @list_id = list_id
  end

  def subscribe
    api.lists.subscribe({
      :id => list_id,
      :email => {
        :email => email
      },
      :double_optin => false
    })
  end

  def unsubscribe
    api.lists.unsubscribe(
      :id => list_id,
      :email => {
        :email => email
      },
      :delete_member => true,
      :send_notify   => false,
      :send_goodbye  => false
    )
  end

  def api
    @api ||= Gibbon::API.new
  end

  def list_id
    @list_id ||= ENV.fetch("MAILCHIMP_LIST_ID")
  end
end

