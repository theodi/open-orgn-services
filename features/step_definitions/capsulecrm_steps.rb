# Setup

Given /^there is no organisation in CapsuleCRM called "(.*?)"$/ do |organisation_name|
  CapsuleCRM::Organisation.find_all(:q => organisation_name).should be_empty
end

Given /^there is an existing organisation in CapsuleCRM called "(.*?)"$/ do |organisation_name|
  CapsuleCRM::Organisation.find_all(:q => organisation_name).should be_empty
  @organisation = CapsuleCRM::Organisation.new(:name => organisation_name)
  @organisation.save
  CapsuleCRM::Organisation.find_all(:q => organisation_name).should_not be_empty
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
  @capsule_cleanup << @person
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

Then /^that person should have the telephone number "(.*?)"$/ do |arg1|
  pending # express the regexp above with the code you wish you had
end

# Opportunities

Then /^that organisation should have an opportunity against it$/ do
  pending # express the regexp above with the code you wish you had
end

Then /^that opportunity should have the name "(.*?)"$/ do |arg1|
  pending # express the regexp above with the code you wish you had
end

Then /^that opportunity should have the description "(.*?)"$/ do |arg1|
  pending # express the regexp above with the code you wish you had
end

Then /^that opportunity should have the value (\d+) per year for (\d+) years$/ do |arg1, arg2|
  pending # express the regexp above with the code you wish you had
end

Then /^that opportunity should have the milestone "(.*?)"$/ do |arg1|
  pending # express the regexp above with the code you wish you had
end

Then /^that opportunity should have the probability (\d+)%$/ do |arg1|
  pending # express the regexp above with the code you wish you had
end

Then /^that opportunity should have an expected close date of (#{DATE})$/ do |date|
  pending # express the regexp above with the code you wish you had
end

Then /^that opportunity should be owned by "(.*?)"$/ do |arg1|
  pending # express the regexp above with the code you wish you had
end

Then /^that opportunity should have a type of "(.*?)"$/ do |arg1|
  pending # express the regexp above with the code you wish you had
end

# Tasks

Then /^that person should have a task against him$/ do
  pending # express the regexp above with the code you wish you had
end

Then /^that task should have the description "(.*?)"$/ do |arg1|
  pending # express the regexp above with the code you wish you had
end

Then /^that task should be due at (\d+)\-(\d+)\-(\d+) (\d+):(\d+)$/ do |arg1, arg2, arg3, arg4, arg5|
  pending # express the regexp above with the code you wish you had
end

Then /^that task should have the category "(.*?)"$/ do |arg1|
  pending # express the regexp above with the code you wish you had
end

Then /^that task should be assigned to "(.*?)"$/ do |arg1|
  pending # express the regexp above with the code you wish you had
end

Then /^that task should have the detailed description "(.*?)"$/ do |arg1|
  pending # express the regexp above with the code you wish you had
end
