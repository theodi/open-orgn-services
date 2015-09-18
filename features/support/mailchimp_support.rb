module MailchimpSupport
  def mailing_list_members
    members = Gibbon::API.new.lists.members(
      { id: ENV.fetch("MAILCHIMP_LIST_ID") }
    )

    members["data"]
  end
end

World(MailchimpSupport)

