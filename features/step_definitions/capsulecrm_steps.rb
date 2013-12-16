# Setup

Given /^there is no organisation in CapsuleCRM called "(.*?)"$/ do |organisation_name|
  CapsuleCRM::Organisation.find_all(:q => organisation_name).should be_empty
end

Given /^there is an existing organisation in CapsuleCRM called "(.*?)"$/ do |organisation_name|
  CapsuleCRM::Organisation.find_all(:q => organisation_name).should be_empty
  @organisation = CapsuleCRM::Organisation.new(:name => organisation_name)
  @organisation.save
  CapsuleCRM::Organisation.find_all(:q => organisation_name).should_not be_empty
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

Given(/^the following sector tags exist in CapsuleCRM:$/) do |table|
  
end

Given(/^the following members exist in CapsuleCRM:$/) do |table|
  membership_length = {
    "sponsor"   => 3.years,
    "partner"   => 3.years,
    "member"    => 1.year,
    "supporter" => 1.year
  }
  table.hashes.each do |row|
    joined = (row["renewal_in_x_weeks"].to_f.weeks.from_now - membership_length[row["level"]]).to_date
    steps %{
      Given there is an existing organisation in CapsuleCRM called "#{row["name"]}"
      And the organisation is a member at level "#{row["level"]}"
      And the organisation joined on #{joined}
      And that organisation has a tag called "#{row["sector"]}"
    }
  end
end

Given(/^the following opportunities exist in CapsuleCRM with paid invoices in Xero if closed:$/) do |table|
  table.hashes.each do |row|
    steps %{
      Given there is an existing organisation in CapsuleCRM called "#{row["organisation"]}"
      And there is an opportunity against that organisation
      And that opportunity is in stage "#{row["stage"]}" with likelihood #{row['likelihood']}
      And that opportunity has the value #{row["value"]} per year for #{row['duration']} years
      And that opportunity is expected to close on #{Date.today + row["close_in_x_weeks"].to_i.weeks}
      And that opportunity was opened on #{Date.today - row["opened_x_days_ago"].to_i.days}
    }
    # if row["stage"] == "Closed"
    #   steps %{
    #     Given there is a contact in Xero for "#{row["organisation"]}"
    #     And that contact has a paid invoice in Xero for #{row["value"]} for "membership" on sales code "membership"
    #     And that invoice was raised on #{Date.today - row["opened_x_weeks_ago"].to_i.weeks}
    #     And that invoice has been paid
    #   }
    # end
  end
end

Then /^an organisation should exist in CapsuleCRM called "(.*?)"$/ do |organisation_name|
  @organisation = CapsuleCRM::Organisation.find_all(:q => organisation_name).first
  @organisation.should_not be_nil
  @capsule_cleanup << @organisation
end

Then /^there should still be just one organisation in CapsuleCRM called "(.*?)"$/ do |organisation_name|
  organisations = CapsuleCRM::Organisation.find_all(:q => organisation_name)
  organisations.size.should == 1
  @organisation = organisations.first
end

Given(/^the organisation is a member at level "(.*?)"$/) do |level|
  tag = CapsuleCRM::Tag.new(
    @organisation,
    :name => 'Membership'
  )
  tag.save
  custom_field = CapsuleCRM::CustomField.new(
    @organisation,
    {
      tag: 'Membership',
      label: 'Level',
      text: level,
    }
  )
  custom_field.save
end

Given(/^the organisation joined on (#{DATE})$/) do |date|
  custom_field = CapsuleCRM::CustomField.new(
    @organisation,
    {
      tag: 'Membership',
      label: 'Joined',
      date: date,
    }
  )
  custom_field.save
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

Given(/^there is an opportunity against that organisation$/) do
  # Create opportunity against organisation
  @opportunity = CapsuleCRM::Opportunity.new(
    :party_id            => @organisation.id, 
    :name                => "Membership",
    :milestone           => 'Closed',
    :probability         => 100,
  )
  @opportunity.save
end

Given(/^that opportunity is in stage "(.*?)" with likelihood (\d+)%$/) do |milestone, likelihood|
  @opportunity.milestone = milestone
  @opportunity.probability = likelihood.to_i
  @opportunity.save
end

Given(/^that opportunity has the value (\d+) per year for (\d+) years$/) do |value, duration|
  @opportunity.value = value.to_i
  @opportunity.duration = duration.to_i
  @opportunity.duration_basis = 'YEAR'
  @opportunity.save
end

Given(/^that opportunity is expected to close on (#{DATE})$/) do |date|
  @opportunity.expected_close_date = date
  @opportunity.save
  # Mock the actual close date, as it's done by capsule internally
  if date <= Date.today
    $opportunity_closed_dates ||= {}
    $opportunity_closed_dates[@opportunity.id] = date.to_s 
    class CapsuleCRM::Opportunity
      def actual_close_date
        $opportunity_closed_dates[id]
      end
    end
  end
end

Given(/^that opportunity was opened on (#{DATE})$/) do |date|
  $opportunity_created_dates ||= {}
  $opportunity_created_dates[@opportunity.id] = date
  # We can't set the actual created date in capsulecrm, so we have to mock it instead.
  # This is AWFUL, but I can't work out how to access the original object ID inside the partial mock.
  # Suggestions accepted!
  class CapsuleCRM::Opportunity
    def created_at
      $opportunity_created_dates[id]
    end
  end
end

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

Given /^that organisation has a tag called "(.*?)"$/ do |tag_name|
  @tag = CapsuleCRM::Tag.new(
    @organisation,
    :name => tag_name
  )
  @tag.save
end

Given /^that organisation has a data tag called "(.*?)"$/ do |tag_name|
  steps %{
    that organisation has a tag called "#{tag_name}"
  }
end

Then /^that organisation should have a data tag$/ do
  tags = @organisation.tags
  tags.size.should == 1
  @tag = tags.first
  @tag.should_not be_nil
end

Then /^that data tag should have the type "(.*?)"$/ do |type|
  @tag.name.should == type
end

Then /^that organisation should have a "(.*?)" data tag$/ do |type|
  @tag = @organisation.tags.find{|x| x.name == type}
  @tag.should_not be_nil
end

Then /^that data tag should have the level "(.*?)"$/ do |level|
  field = @organisation.custom_fields.find{|x| x.label == "Level" && x.tag == @tag.name}
  field.should be_present
  field.text.should == level
end

Then /^that data tag should have the join date (#{DATE})$/ do |date|
  field = @organisation.custom_fields.find{|x| x.label == "Joined" && x.tag == @tag.name}
  field.should be_present
  field.date.should == date
end

Then /^that data tag should have the membership number "(.*?)"$/ do |membership_number|
  field = @organisation.custom_fields.find{|x| x.label == "ID" && x.tag == @tag.name}
  field.should be_present
  field.text.should == membership_number
end

Then /^that data tag should have the email "(.*?)"$/ do |email|
  field = @organisation.custom_fields.find{|x| x.label == "Email" && x.tag == @tag.name}
  field.should be_present
  field.text.should == email
end

