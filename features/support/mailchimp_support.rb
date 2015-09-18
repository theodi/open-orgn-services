module MailchimpSupport
  def mailing_list_members
    members = Gibbon::API.new.lists.members(
      { id: ENV.fetch("MAILCHIMP_LIST_ID") }
    )

    members["data"].map { |member| member["email"] }
  end
end

World(MailchimpSupport)

