Then /^my signup should be requeued for later processing once the contact has synced from Xero$/ do
  organization = {
    'name' => @company,
    'company_number' => @company_number,
    'email' => @email || @invoice_email
  }
  membership  = {
    'product_name'    => @membership_level,
    'supporter_level' => "Supporter",
    'id'              => @membership_id.to_s,
    'join_date'       => Date.today.to_s,
    'contact_email'   => @email,
    'size'            => @size,
    'sector'          => @sector
  }
  Resque.should_receive(:enqueue_in).with(1.hour, SendSignupToCapsule, organization, membership).once
end

When /^I sign up via the website$/ do
  organization = {
    'name' => @company || @contact_name,
    'company_number' => @company_number,
    'email' => @email
  }.compact
  membership  = {
    'product_name'    => @membership_level,
    'supporter_level' => @membership_level.titleize,
    'id'              => @membership_id.to_s,
    'join_date'       => Date.today.to_s,
    'contact_email'   => @email,
    'size'            => @size,
    'sector'          => @sector
  }.compact
  SendSignupToCapsule.perform(organization, membership)
end

Then /^I should be added to the capsulecrm queue$/ do
  organization = {
    'name' => @company,
    'company_number' => @company_number,
    'email' => @invoice_email
  }.compact
  membership  = {
    'product_name'     => @membership_level,
    'supporter_level'  => @supporter_level,
    'id'               => @membership_id.to_s,
    'join_date'        => Date.today.to_s,
    'contact_email'    => @email,
    'size'             => @size,
    'sector'           => @sector
  }.compact
  Resque.should_receive(:enqueue).with(SendSignupToCapsule, organization, membership).once
end

Then(/^my organisation contact details should exist in CapsuleCRM$/) do
  org = CapsuleCRM::Organisation.find_all(:q => @company).first
  expect(org.name).to eq(@company)
  expect(org.emails.first.address).to eq(@invoice_email)
  @capsule_cleanup << org
end

Then(/^my contact details should exist in CapsuleCRM$/) do
  person = CapsuleCRM::Person.find_all(:q => @name).first
  first_name, last_name = @name.split(" ")
  expect(person.first_name).to eq(first_name)
  expect(person.last_name).to eq(last_name)

  expect(person.emails.first.address).to eq(@invoice_email)
  @capsule_cleanup << person
end
