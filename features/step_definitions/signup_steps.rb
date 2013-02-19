class User
  def initialize(user)
    Resque.enqueue(SignupProcessor, user)
  end
end

class SignupProcessor
end

Given /^that I want to sign up as a (\w*)$/ do |level|
  @level = level
end

When /^I visit the signup page$/ do
  # We don't have a signup page yet!
end

When /^I enter my details$/ do
  @organisation_name = 'FooBar Inc'
  @first_name = 'Ian'
  @last_name = 'McIain'
  @email = 'iain@foobar.com'
  @phone = '0121 123 446'
  @address_line1 = '123 Fake Street'
  @address_line2 = 'Fake place'
  @address_city = 'Faketown'
  @address_region = 'Fakeshire'
  @address_country = 'UK'
  @address_postcode = 'FAKE 123'
  @tax_number = '213244343'
  @purchase_order_number = 'PO-43243242342'
end

When /^I agree to the terms and conditions$/ do
  @agreed_to_terms = true
end

When /^I click sign up$/ do
  user = User.new({
    :level => @level,
    :organisation_name => @organisation_name,
    :first_name => @first_name,
    :last_name => @last_name,
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
    :first_name => @first_name,
    :last_name => @last_name,
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