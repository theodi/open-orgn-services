class MailchimpCleaner
  def self.clean!(members)
    new(members).clean
  end

  attr_reader :members

  def initialize(members)
    @members = members
  end

  def list
    Gibbon::API.new(api_key).lists
  end

  def api_key
    @api_key ||= ENV.fetch("MAILING_LIST_API_KEY")
  end

  def list_id
    @list_id ||= ENV.fetch("MAILING_LIST_LIST_ID")
  end

  def clean
    members.each do |member|
      member.emails.each do |email|
        list.unsubscribe(
          id: list_id,
          email: {
            email: email.address
          },
          send_notify: false
        )
      end
    end
  rescue Gibbon::MailChimpError
    # We don't care
  end
end

