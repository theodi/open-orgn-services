Then /^my signup should be requeued for later processing once the contact has synced from Xero$/ do
  organization = {
    'name' => @company,
    'company_number' => @company_number
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
    'company_number' => @company_number
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
    'company_number' => @company_number
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
