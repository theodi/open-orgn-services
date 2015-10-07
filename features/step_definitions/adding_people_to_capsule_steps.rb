Given /^I have signed up as an individual member$/ do
  @contact_name  = "Arnold Rimmer"
  @contact_phone = "+44 7473 439430"
  @email = "rimmer@jmc.com"
  @membership_level = "individual"
end

Given(/^there is no person in CapsuleCRM called "(.*?)"$/) do |person_name|
  expect(CapsuleCRM::Person.find_all(:q => person_name)).to be_empty
end

Given(/^there is an existing person in CapsuleCRM called "(.*?)" with email "(.*?)"$/) do |person_name, email|
  expect(CapsuleCRM::Person.find_all(:email => email)).to be_empty
  @person = CapsuleCRM::Person.new(:first_name => person_name.split(" ")[0], last_name: person_name.split(" ")[1])
  @person.emails << CapsuleCRM::Email.new(@person, address: email)
  @person.save
  expect(CapsuleCRM::Person.find_all(:email => email)).not_to be_empty
  @capsule_cleanup << @person
end

Given(/^there should still be just one person in CapsuleCRM called "(.*?)" with email "(.*?)"$/) do |person_name, email|
  p = CapsuleCRM::Person.find_all(:email => email).first
  expect(p).not_to be_nil
  expect(p.first_name).to eq(person_name.split(" ")[0])
  expect(p.last_name).to eq(person_name.split(" ")[1])
  @person ||= p
  @capsule_cleanup << @person
end

Given(/^that person is a member$/) do
  tag = CapsuleCRM::Tag.new(
  @person,
  :name => "Membership"
  )
  tag.save
  {
    "ID" => @membership_id
  }.each_pair do |field, value|
    field = CapsuleCRM::CustomField.new(
    @person,
    :tag => tag.name,
    :label => field,
    :text => value,
    :boolean => (value == "true")
    )
    field.save
  end
end

Given(/^I change my details$/) do
  pending # express the regexp above with the code you wish you had
end

Then(/^that person should have a data tag$/) do
  tags = @person.tags
  expect(tags.size).to eq(1)
  @tag = tags.first
  expect(@tag).not_to be_nil
  @party = @person
end

Then(/^that person should have a data tag called "(.*?)"$/) do |arg1|
  pending # express the regexp above with the code you wish you had
end

Then(/^that data tag should have the following fields:$/) do |table|
  # table is a Cucumber::Ast::Table
  pending # express the regexp above with the code you wish you had
end
