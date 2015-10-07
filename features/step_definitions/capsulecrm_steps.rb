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
  expect(@organisation.people).to be_empty
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
  expect(person).to be_present
  @capsule_cleanup << person
end

# Organisations

Then /^an organisation should exist in CapsuleCRM called "(.*?)"$/ do |organisation_name|
  @organisation = CapsuleCRM::Organisation.find_all(:q => organisation_name).first
  expect(@organisation).not_to be_nil
  @capsule_cleanup << @organisation
end

Then /^there should still be just one organisation in CapsuleCRM called "(.*?)"$/ do |organisation_name|
  organisations = CapsuleCRM::Organisation.find_all(:q => organisation_name)
  expect(organisations.size).to eq(1)
  @organisation = organisations.first
  @capsule_cleanup << @organisation
end

# People

Then /^that organisation should have a person$/ do
  @person = @organisation.people.first
  expect(@person).to be_present
end

Then /^that organisation should have just one person$/ do
  expect(@organisation.people.count).to eq(1)
  @person = @organisation.people.first
end

Then /^that person should have the first name "(.*?)"$/ do |name|
  expect(@person.first_name).to eq(name)
end

Then /^that person should have the last name "(.*?)"$/ do |name|
  expect(@person.last_name).to eq(name)
end

Then /^that person should have the job title "(.*?)"$/ do |job_title|
  expect(@person.job_title).to eq(job_title)
end

Then /^that person should have the email address "(.*?)"$/ do |email|
  expect(@person.emails.first.address).to eq(email)
end

Then /^that person should have the telephone number "(.*?)"$/ do |number|
  expect(@person.phone_numbers.first.number).to eq(number)
end

# Opportunities

Then /^that organisation should have an opportunity against it$/ do
  @opportunity = @organisation.opportunities.first
  expect(@opportunity).not_to be_nil
end

Then /^that opportunity should have the name "(.*?)"$/ do |name|
  expect(@opportunity.name).to eq(name)
end

Then /^that opportunity should have the description "(.*?)"$/ do |description|
  expect(@opportunity.description).to eq(description)
end

Then /^that opportunity should have the value (#{INTEGER}) per (.*?) for (#{INTEGER}) .*?$/ do |value, basis, duration|
  expect(@opportunity.value.to_f).to eq(value.to_f)
  expect(@opportunity.duration_basis).to eq(basis.upcase)
  expect(@opportunity.duration).to eq(duration.to_s)
end

Then /^that opportunity should have the milestone "(.*?)"$/ do |milestone|
  expect(@opportunity.milestone).to eq(milestone)
end

Then /^that opportunity should have the probability (#{INTEGER})%$/ do |probability|
  expect(@opportunity.probability).to eq(probability.to_s)
end

Then /^that opportunity should have an expected close date of (#{DATE})$/ do |date|
  expect(Date.parse(@opportunity.expected_close_date)).to eq(date)
end

Then /^that opportunity should be owned by "(.*?)"$/ do |owner|
  expect(@opportunity.owner).to eq(owner)
end

Then /^that opportunity should have a type of "(.*?)"$/ do |type|
  field = @opportunity.custom_fields.find{|x| x.label == "Type"}
  expect(field).to be_present
  expect(field.text).to eq(type)
end

# Tasks

Then /^that person should have a task against him$/ do
  @task = @person.tasks.first
  expect(@task).to be_present
end

Then /^that task should have the description "(.*?)"$/ do |description|
  expect(@task.description).to eq(description)
end

Then /^that task should be due at (#{DATETIME})$/ do |due|
  expect(DateTime.parse(@task.due_date_time)).to eq(due)
end

Then /^that task should have the category "(.*?)"$/ do |category|
  expect(@task.category).to eq(category)
end

Then /^that task should be assigned to "(.*?)"$/ do |owner|
  expect(@task.owner).to eq(owner)
end

Then /^that task should have the detailed description "(.*?)"$/ do |detail|
  expect(@task.detail).to eq(detail)
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
  expect(@tag).not_to be be_nil
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
  expect(field).to be_present
  field.text.should == origin
end

Then(/^that organisation should have a company number "(.*?)"$/) do |company_number|
  field = @organisation.custom_fields.find{|x| x.label == "Company Number"}
  expect(field).to be_present
  expect(field.text).to eq(company_number)
end

Then(/^that data tag should have the supporter level "(.*?)"$/) do |level|
  field = @party.custom_fields.find{|x| x.label == "Supporter Level" && x.tag == @tag.name}
  expect(field).to be_present
  expect(field.text).to eq(level)
end

Then(/^that data tag should have the size "(.*?)"$/) do |size|
  field = @party.custom_fields.find{|x| x.label == "Size" && x.tag == @tag.name}
  expect(field).to be_present
  expect(field.text).to eq(size)
end

Then(/^that data tag should have the sector "(.*?)"$/) do |sector|
  field = @party.custom_fields.find{|x| x.label == "Sector" && x.tag == @tag.name}
  expect(field).to be_present
  expect(field.text).to eq(sector)
end

Then(/^that data tag should have the university email "(.*?)"$/) do |university_email|
  field = @party.custom_fields.find{|x| x.label == "University email" && x.tag == @tag.name}
  expect(field).to be_present
  expect(field.text).to eq(university_email)
end

Then(/^that data tag should have the contact first name of "(.*?)"$/) do |first_name|
  field = @party.custom_fields.find{|x| x.label == "Contact first name" && x.tag == @tag.name}
  expect(field).to be_present
  expect(field.text).to eq(first_name)
end

Then(/^that data tag should have the contact last name of "(.*?)"$/) do |last_name|
  field = @party.custom_fields.find{|x| x.label == "Contact last name" && x.tag == @tag.name}
  expect(field).to be_present
  expect(field.text).to eq(last_name)
end

