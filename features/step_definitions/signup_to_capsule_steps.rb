Then /^my signup should be requeued for later processing once the contact has synced from Xero$/ do
  membership  = {
    'product_name' => @product_name,
    'number'       => @membership_number,
    'join_date'    => @join_date
  }
  organization = {
    'name' => @company
  }
  Resque.should_receive(:enqueue_in).with(1.hour, SendSignupToCapsule, organization, membership).once
end

When /^I sign up via the website$/ do
  pending # express the regexp above with the code you wish you had
end

Then /^I should be added to the capsulecrm queue$/ do
  
end