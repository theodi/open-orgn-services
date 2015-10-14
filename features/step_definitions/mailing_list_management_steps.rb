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

Given(/^that a member is already on the mailing list and is reprocessed$/) do

  # Member is already on the mailing list
  Gibbon::API.new(ENV.fetch("MAILING_LIST_API_KEY")).lists.subscribe({
    :id => ENV.fetch("MAILING_LIST_LIST_ID"),
    :email => {
      :email => "shane_fadel@kris.net"
    },
    :merge_vars => {
      :FNAME      => "Existing first name",
      :LNAME      => "Existing last name",
      :LEVEL      => "individual",
      :COUNTRY    => "United Kingdom",
      :TWITTER    => "@existing_twitter",
      :JOIN_DATE  => "01/01/2015",
      :ORG_SECTOR => "Health",
      :ORG_NAME   => "Existing org name",
      :ORG_SIZE   => "<10"
    },
    :double_optin => false
  })

  # New details in Capsule
  @member = CapsuleCRM::Organisation.new(name: "New org name")
  @member.emails << CapsuleCRM::Email.new(@member, address: "shane_fadel@kris.net")
  @member.save

  CapsuleCRM::Tag.new(@member, :name => "Membership").save

  [
    { tag: "Membership", label: "Newsletter",         boolean: true },
    { tag: "Membership", label: "Level",              text: "supporter" },
    { tag: "Membership", label: "Contact first name", text: "New first name" },
    { tag: "Membership", label: "Contact last name",  text: "New last name" },
    { tag: "Membership", label: "Country",            text: "France" },
    { tag: "Membership", label: "Twitter",            text: "@new_twitter" },
    { tag: "Membership", label: "Joined",             date: Date.parse("02/02/2015") },
    { tag: "Membership", label: "Sector",             text: "Education" },
    { tag: "Membership", label: "Size",               text: ">1000" }
  ].each do |attributes|
    CapsuleCRM::CustomField.new(@member, attributes).save
  end

  # Comment to leave members in Capsule for debugging
  @capsule_cleanup << @member
  @mailchimp_cleanup << @member
end

Then(/^the members details will be updated$/) do
  email_addresses = mailing_list_members.map { |s| s["email"] }
  member = mailing_list_members.find { |s| s["email"] == @member.emails.first.address }

  expect(email_addresses).to include(@member.emails.first.address)
  expect(member["merges"]["FNAME"]).to eq("New first name")
  expect(member["merges"]["LNAME"]).to eq("New last name")
  expect(member["merges"]["LEVEL"]).to eq("supporter")
  expect(member["merges"]["COUNTRY"]).to eq("France")
  expect(member["merges"]["TWITTER"]).to eq("@new_twitter")
  expect(member["merges"]["JOIN_DATE"]).to eq("2015-02-02")
  expect(member["merges"]["ORG_SECTOR"]).to eq("Education")
  expect(member["merges"]["ORG_NAME"]).to eq("New org name")
  expect(member["merges"]["ORG_SIZE"]).to eq(">1000")
end

