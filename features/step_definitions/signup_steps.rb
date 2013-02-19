Given /^that I want to sign up as a (\w*)$/ do |level|
  @level = level # Required
end

Given /^that I want to sign up$/ do
  @level = 'supporter'
end

When /^I visit the signup page$/ do
  # We don't have a signup page yet!
end

When /^I enter my details$/ do
  @organisation_name = 'FooBar Inc'
  @contact_name = 'Ian McIain' # Required
  @email = 'iain@foobar.com' # Required
  @phone = '0121 123 446'
  @address_line1 = '123 Fake Street' # Required
  @address_line2 = 'Fake place'
  @address_city = 'Faketown' # Required
  @address_region = 'Fakeshire'
  @address_country = 'UK' # Required
  @address_postcode = 'FAKE 123'
  @tax_number = '213244343'
  @purchase_order_number = 'PO-43243242342'
  @agreed_to_terms = true
end

When /^I haven't chosen a membership level$/ do
  @level = nil
end

When /^I don't enter my name$/ do
  @contact_name = nil
end

When /^I don't enter my email$/ do
  @email = nil
end

When /^I don't enter Address Line 1$/ do
  @address_line1 = nil
end

When /^I don't enter my city$/ do
  @address_city = nil
end

When /^I don't enter my country$/ do
  @address_country = nil
end

When /^I don't agree to the terms and conditions$/ do
  @agreed_to_terms = nil
end

When /^I click sign up$/ do
  @user = User.new({
    :level => @level,
    :organisation_name => @organisation_name,
    :contact_name => @contact_name,
    :email => @email,
    :phone => @phone,
    :address_line1 => @address_line1,
    :address_line2 => @address_line2,
    :address_city => @address_city,
    :address_region => @address_region,
    :address_country => @address_country,
    :address_postcode => @address_postcode,
    :tax_number => @tax_number,
    :purchase_order_number => @purchase_order_number,
    :agreed_to_terms => @agreed_to_terms
  })
end

Then /^my details should be queued for further processing$/ do

  user = {
    :level => @level,
    :organisation_name => @organisation_name,
    :contact_name => @contact_name,
    :email => @email,
    :phone => @phone,
    :address_line1 => @address_line1,
    :address_line2 => @address_line2,
    :address_city => @address_city,
    :address_region => @address_region,
    :address_country => @address_country,
    :address_postcode => @address_postcode,
    :tax_number => @tax_number,
    :purchase_order_number => @purchase_order_number,
    :agreed_to_terms => @agreed_to_terms
  }

  Resque.should_receive(:enqueue).with(SignupProcessor, user).once
end

Then /^I should see an error$/ do
  @user.errors.should_not be_empty
end

Then /^my details should not be queued$/ do
  Resque.should_not_receive(:enqueue)
end