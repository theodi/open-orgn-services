# Setup

Given /^there is no organisation in CapsuleCRM called "(.*?)"$/ do |organisation_name|
  expect(CapsuleCRM::Organisation.find_all(:q => organisation_name)).to be_empty
end

Given /^there is an existing organisation in CapsuleCRM called "(.*?)"$/ do |organisation_name|
  expect(CapsuleCRM::Organisation.find_all(:q => organisation_name)).to be_empty
  @organisation = CapsuleCRM::Organisation.new(:name => organisation_name)
  @organisation.save
  expect(CapsuleCRM::Organisation.find_all(:q => organisation_name)).not_to be_empty
  @capsule_cleanup << @organisation
end

Given /^that organisation does not have a person$/ do
  @organisation.people.should be_empty
end

Given /^that organisation has a person called "(.*?)"$/ do |name|
  p = CapsuleCRM::Person.new(
    :organisation_id => @organisation.id,
    :first_name => name.split(' ', 2)[0],
    :last_name => name.split(' ', 2)[1]
  )
  p.save
  person = @organisation.people.find do |p|
    [p.first_name, p.last_name].compact.join(' ') == name
  end
  person.should be_present
  @capsule_cleanup << person
end

# Organisations

Then /^an organisation should exist in CapsuleCRM called "(.*?)"$/ do |organisation_name|
  @organisation = CapsuleCRM::Organisation.find_all(:q => organisation_name).first
  @organisation.should_not be_nil
  @capsule_cleanup << @organisation
end

Then /^there should still be just one organisation in CapsuleCRM called "(.*?)"$/ do |organisation_name|
  organisations = CapsuleCRM::Organisation.find_all(:q => organisation_name)
  organisations.size.should == 1
  @organisation = organisations.first
  @capsule_cleanup << @organisation
end

# People

Then /^that organisation should have a person$/ do
  @person = @organisation.people.first
  @person.should be_present
end

Then /^that organisation should have just one person$/ do
  @organisation.people.count.should == 1
  @person = @organisation.people.first
end

Then /^that person should have the first name "(.*?)"$/ do |name|
  @person.first_name.should == name
end

Then /^that person should have the last name "(.*?)"$/ do |name|
  @person.last_name.should == name
end

Then /^that person should have the job title "(.*?)"$/ do |job_title|
  @person.job_title.should == job_title
end

Then /^that person should have the email address "(.*?)"$/ do |email|
  @person.emails.first.address.should == email
end

Then /^that person should have the telephone number "(.*?)"$/ do |number|
  @person.phone_numbers.first.number.should == number
end

# Opportunities

Then /^that organisation should have an opportunity against it$/ do
  @opportunity = @organisation.opportunities.first
  @opportunity.should_not be_nil
end

Then /^that opportunity should have the name "(.*?)"$/ do |name|
  @opportunity.name.should == name
end

Then /^that opportunity should have the description "(.*?)"$/ do |description|
  @opportunity.description.should == description
end

Then /^that opportunity should have the value (#{INTEGER}) per (.*?) for (#{INTEGER}) .*?$/ do |value, basis, duration|
  @opportunity.value.to_f.should == value.to_f
  @opportunity.duration_basis.should == basis.upcase
  @opportunity.duration.should == duration.to_s
end

Then /^that opportunity should have the milestone "(.*?)"$/ do |milestone|
  @opportunity.milestone.should == milestone
end

Then /^that opportunity should have the probability (#{INTEGER})%$/ do |probability|
  @opportunity.probability.should == probability.to_s
end

Then /^that opportunity should have an expected close date of (#{DATE})$/ do |date|
  Date.parse(@opportunity.expected_close_date).should == date
end

Then /^that opportunity should be owned by "(.*?)"$/ do |owner|
  @opportunity.owner.should == owner
end

Then /^that opportunity should have a type of "(.*?)"$/ do |type|
  field = @opportunity.custom_fields.find{|x| x.label == "Type"}
  field.should be_present
  field.text.should == type
end

# Tasks

Then /^that person should have a task against him$/ do
  @task = @person.tasks.first
  @task.should be_present
end

Then /^that task should have the description "(.*?)"$/ do |description|
  @task.description.should == description
end

Then /^that task should be due at (#{DATETIME})$/ do |due|
  DateTime.parse(@task.due_date_time).should == due
end

Then /^that task should have the category "(.*?)"$/ do |category|
  @task.category.should == category
end

Then /^that task should be assigned to "(.*?)"$/ do |owner|
  @task.owner.should == owner
end

Then /^that task should have the detailed description "(.*?)"$/ do |detail|
  @task.detail.should == detail
end

# Data tags

Given /^that (organisation|person) has a tag called "(.*?)"$/ do |target, tag_name|
  @tag = CapsuleCRM::Tag.new(
    instance_variable_get("@#{target}"),
    :name => tag_name
  )
  @tag.save
end

Given /^that organisation has a data tag called "(.*?)"$/ do |tag_name|
  steps %{
    Given that organisation has a tag called "#{tag_name.to_s}"
  }
end

Then /^that organisation should have a data tag$/ do
  tags = @organisation.tags
  tags.size.should == 1
  @tag = tags.first
  @tag.should_not be_nil
  @party = @organisation
end

Then /^that data tag should have the type "(.*?)"$/ do |type|
  expect(@tag.name).to eq(type)
end

Then /^that organisation should have a "(.*?)" data tag$/ do |type|
  @tag = @organisation.tags.find{|x| x.name == type}
  @tag.should_not be_nil
  @party = @organisation
end

Then /^that data tag should have the level "(.*?)"$/ do |level|
  field = @party.custom_fields.find{|x| x.label == "Level" && x.tag == @tag.name}
  expect(field).to be_present
  expect(field.text).to eq(level)
end

Then /^that data tag should have the join date (#{DATE})$/ do |date|
  field = @party.custom_fields.find{|x| x.label == "Joined" && x.tag == @tag.name}
  expect(field).to be_present
  expect(field.date).to eq(date)
end

Then /^that data tag should have the membership number "(.*?)"$/ do |membership_number|
  field = @party.custom_fields.find{|x| x.label == "ID" && x.tag == @tag.name}
  expect(field).to be_present
  expect(field.text).to eq(membership_number)
end

Then /^that data tag should have the email "(.*?)"$/ do |email|
  field = @party.custom_fields.find{|x| x.label == "Email" && x.tag == @tag.name}
  expect(field).to be_present
  expect(field.text).to eq(email)
end

Then(/^that data tag should have the origin "(.*?)"$/) do |origin|
  field = @party.custom_fields.find{|x| x.label == "Origin" && x.tag == @tag.name}
  field.should be_present
  field.text.should == origin
end

Then(/^that organisation should have a company number "(.*?)"$/) do |company_number|
  field = @organisation.custom_fields.find{|x| x.label == "Company Number"}
  field.should be_present
  field.text.should == company_number
end

Then(/^that data tag should have the supporter level "(.*?)"$/) do |level|
  field = @party.custom_fields.find{|x| x.label == "Supporter Level" && x.tag == @tag.name}
  field.should be_present
  field.text.should == level
end

Then(/^that data tag should have the size "(.*?)"$/) do |size|
  field = @party.custom_fields.find{|x| x.label == "Size" && x.tag == @tag.name}
  field.should be_present
  field.text.should == size
end

Then(/^that data tag should have the sector "(.*?)"$/) do |sector|
  field = @party.custom_fields.find{|x| x.label == "Sector" && x.tag == @tag.name}
  expect(field).to be_present
  expect(field.text).to eq(sector)
end

Then(/^that data tag should have the university email "(.*?)"$/) do |university_email|
  field = @party.custom_fields.find{|x| x.label == "University email" && x.tag == @tag.name}
  field.should be_present
  field.text.should == university_email
end

Then(/^that data tag should have the contact first name of "(.*?)"$/) do |first_name|
  field = @party.custom_fields.find{|x| x.label == "Contact first name" && x.tag == @tag.name}
  field.should be_present
  field.text.should == first_name
end

Then(/^that data tag should have the contact last name of "(.*?)"$/) do |last_name|
  field = @party.custom_fields.find{|x| x.label == "Contact last name" && x.tag == @tag.name}
  field.should be_present
  field.text.should == last_name
end

