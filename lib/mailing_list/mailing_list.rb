require 'gibbon'

class MailingList

  def self.subscribe(email)
    mailchimp = Gibbon::API.new
    mailchimp.lists.subscribe({
      :id => ENV.fetch("MAILCHIMP_LIST_ID"),
      :email => {
        :email => email
      },
      :double_optin => false
    })
  end

  def self.unsubscribe(email)
    mailchimp = Gibbon::API.new
    mailchimp.lists.unsubscribe(
      :id => ENV.fetch("MAILCHIMP_LIST_ID"),
      :email => {
        :email => email
      },
      :delete_member => true,
      :send_notify   => false,
      :send_goodbye  => false
    )
  end
end

