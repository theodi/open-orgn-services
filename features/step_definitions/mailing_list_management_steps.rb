Given(/^that a member has requested to (NOT be on|be on) the mailing list$/) do |subscribe_or_unsubcribe|
  receive_newsletter = (subscribe_or_unsubcribe == "be on" ? true : false)

  # Create member in Capsule
  @member = CapsuleCRM::Organisation.new(name: "Foobar Inc")
  @member.emails << CapsuleCRM::Email.new(@member, address: "shane_fadel@kris.net")
  @member.save

  # Save membership tag
  CapsuleCRM::Tag.new(@member, :name => "Membership").save

  # Create custom fields in Capsule CRM
  [
    { tag: "Membership", label: "Newsletter",         boolean: receive_newsletter },
    { tag: "Membership", label: "Level",              text: "supporter" },
    { tag: "Membership", label: "Contact first name", text: "Test" },
    { tag: "Membership", label: "Contact last name",  text: "Example" },
    { tag: "Membership", label: "Country",            text: "United Kingdom" },
    { tag: "Membership", label: "Twitter",            text: "@twitter" },
    { tag: "Membership", label: "Joined",             date: Date.parse("01/01/2015") },
    { tag: "Membership", label: "Sector",             text: "Education" },
    { tag: "Membership", label: "Size",               text: ">1000" }
  ].each do |attributes|
    CapsuleCRM::CustomField.new(@member, attributes).save
  end

  # Comment to leave members in Capsule for debugging
  @capsule_cleanup << @member
  @mailchimp_cleanup << @member
end

Given(/^the member is already on the mailing list$/) do
  Gibbon::API.new(ENV.fetch("MAILING_LIST_API_KEY")).lists.subscribe({
    :id => ENV.fetch("MAILING_LIST_LIST_ID"),
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
  expect(member["merges"]["FNAME"]).to eq("Test")
  expect(member["merges"]["LNAME"]).to eq("Example")
  expect(member["merges"]["COUNTRY"]).to eq("United Kingdom")
  expect(member["merges"]["TWITTER"]).to eq("@twitter")
  expect(member["merges"]["JOIN_DATE"]).to eq("2015-01-01")
  expect(member["merges"]["ORG_SECTOR"]).to eq("Education")
  expect(member["merges"]["ORG_NAME"]).to eq("Foobar Inc")
  expect(member["merges"]["ORG_SIZE"]).to eq(">1000")
end

Then(/^the member will unsubscribed to the mailing list$/) do
  email_addresses = mailing_list_members.map { |s| s["email"] }

  expect(email_addresses).to_not include(@member.emails.first.address)
end

