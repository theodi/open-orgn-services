Given(/^that a member has requested to (NOT be on|be on) the mailing list in the 24 hours$/) do |subscribe_or_unsubcribe|
  receive_newsletter = (subscribe_or_unsubcribe == "be on" ? true : false)

  # Create member in Capsule
  @member = CapsuleCRM::Organisation.new(name: Faker::Company.name)
  @member.emails << CapsuleCRM::Email.new(@member, address: Faker::Internet.email)
  @member.save

  # Save membership tag
  CapsuleCRM::Tag.new(@member, :name => "Membership").save

  # Save newsletter preference to true
  CapsuleCRM::CustomField.new(@member, {
    label: "Newsletter",
    boolean: receive_newsletter,
    tag: "Membership"
  }).save

  # Save supporter level
  CapsuleCRM::CustomField.new(@member, {
    label: "Level",
    text: "supporter",
    tag: "Membership"
  }).save

  # Comment to leave members in Capsule for debugging
  @capsule_cleanup << @member
  @mailchimp_cleanup << @member
end

Given(/^the member is already on the mailing list$/) do
  Gibbon::API.new.lists.subscribe({
    :id => ENV.fetch("MAILCHIMP_LIST_ID"),
    :email => {
      :email => @member.emails.first.address
    },
    :double_optin => false
  })
end

When(/^the mailing list syncronization job runs$/) do
  Resque.inline = true # Runs all child jobs immediately

  SyncMailingList.perform
end

Then(/^the member will subscribed to the mailing list$/) do
  email_addresses = mailing_list_members.map { |s| s["email"] }
  member = mailing_list_members.find { |s| s["email"] == @member.emails.first.address }

  expect(email_addresses).to include(@member.emails.first.address)
  expect(member["merges"]["LEVEL"]).to eq("supporter")
end

Then(/^the member will unsubscribed to the mailing list$/) do
  email_addresses = mailing_list_members.map { |s| s["email"] }

  expect(email_addresses).to_not include(@member.emails.first.address)
end

