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
    'sector'          => @sector,
    'origin'          => @origin
  }.compact
  SendSignupToCapsule.perform(organization, membership)
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
