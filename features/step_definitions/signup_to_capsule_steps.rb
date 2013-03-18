Then /^my signup should be requeued for later processing once the contact has synced from Xero$/ do
  organization = {
    'name' => @company
  }
  membership  = {
    'product_name' => @membership_level,
    'id'           => @membership_id.to_s,
    'join_date'    => Date.today.to_s,
    'contact_email'=> @email
  }
  Resque.should_receive(:enqueue_in).with(1.hour, SendSignupToCapsule, organization, membership).once
end

When /^I sign up via the website$/ do
  organization = {
    'name' => @company
  }
  membership  = {
    'product_name' => @membership_level,
    'id'           => @membership_id.to_s,
    'join_date'    => Date.today.to_s,
    'contact_email'=> @email
  }
  SendSignupToCapsule.perform(organization, membership)
end

Then /^I should be added to the capsulecrm queue$/ do
  organization = {
    'name' => @company
  }
  membership  = {
    'product_name' => @membership_level,
    'id'           => @membership_id.to_s,
    'join_date'    => Date.today.to_s,
    'contact_email'=> @email
  }
  Resque.should_receive(:enqueue).with(SendSignupToCapsule, organization, membership).once
end