module MailchimpSupport
  def mailing_list_members
    members = Gibbon::API.new(ENV.fetch("MAILING_LIST_API_KEY")).lists.members(
      { id: ENV.fetch("MAILING_LIST_LIST_ID") }
    )

    members["data"]
  end
end

World(MailchimpSupport)

