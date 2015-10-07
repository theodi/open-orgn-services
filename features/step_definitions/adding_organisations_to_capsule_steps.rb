Given /^I enter my organisation details$/ do
  @name          = "The RAND Corporation"
  @description   = "Lorem ipsum dolor sit amet, consectetur adipiscing elit."
  @homepage      = "http://www.example.com"
  @logo          = "http://stuff.theodi.org/images/acmelogo.png"
  @thumb         = "http://stuff.theodi.org/images/thumbs/acmelogo.png"
  @contact_name  = "Arnold Rimmer"
  @contact_phone = "+44 7473 439430"
  @contact_email = "rimmer@jmc.com"
  @twitter       = "rimmer"
  @linkedin      = "http://linkedin.com/company/jmc"
  @facebook      = "http://facebook.com/pages/jmc"
  @tagline       = "empowering synergistic solutions"
end

Given /^I enter a description that is (#{INTEGER}) characters long$/ do |length|
  @description = 'a'*length
end

Given /^I change my organisation details$/ do
  # Store old details
  @original_name          = @name
  @original_description   = @description
  @original_homepage      = @homepage
  @original_logo          = @logo
  @original_thumb         = @thumb
  @original_contact_name  = @contact_name
  @original_contact_phone = @contact_phone
  @original_contact_email = @contact_email
  @original_twitter       = @twitter
  @original_linkedin      = @linkedin
  @original_facebook      = @facebook
  @original_tagline       = @tagline
  # Update details
  @name          = "The RAND Corporation"
  @description   = "Bacon ipsum dolor sit amet pig strip steak jerky shankle sausage prosciutto"
  @homepage      = "http://www.example.com/homepage"
  @logo          = "http://stuff.theodi.org/images/acmelogo_new.png"
  @thumb         = "http://stuff.theodi.org/images/thumbs/acmelogo_new.png"
  @contact_name  = "Arnold J Rimmer"
  @contact_phone = "+44 7473 439430 x42"
  @contact_email = "a.j.rimmer@jmc.com"
  @twitter       = "ajrimmer"
  @linkedin      = "http://linkedin.com/company/j-m-c"
  @facebook      = "http://facebook.com/pages/j-m-c"
  @tagline       = "synergising solution empowerment"
end

When /^the directory entry job runs$/ do
  organization = {
      'name'        => @name
  }
  directory_entry = {
      'description' => @description,
      'homepage'    => @homepage,
      'logo'        => @logo,
      'thumbnail'   => @thumb,
      'contact'     => @contact_name,
      'phone'       => @contact_phone,
      'email'       => @contact_email,
      'twitter'     => @twitter,
      'linkedin'    => @linkedin,
      'facebook'    => @facebook,
      'tagline'     => @tagline,
  }
  date = DateTime.now.to_s

  SendDirectoryEntryToCapsule.perform(@membership_id, organization, directory_entry, date)
end

Then /^my directory entry should be requeued for later processing once the contact has synced from Xero$/ do
  organization = {
      'name'        => @name
  }
  directory_entry = {
      'description' => @description,
      'homepage'    => @homepage,
      'logo'        => @logo,
      'thumbnail'   => @thumb,
      'contact'     => @contact_name,
      'phone'       => @contact_phone,
      'email'       => @contact_email,
      'twitter'     => @twitter,
      'linkedin'    => @linkedin,
      'facebook'    => @facebook,
      'tagline'     => @tagline,
  }
  date = DateTime.now.to_s

  expect(Resque).to receive(:enqueue_in).with(1.hour, SendDirectoryEntryToCapsule, @membership_id, organization, directory_entry, date).once
end

Given /^that organisation is a member$/ do
  tag = CapsuleCRM::Tag.new(
    @organisation,
    :name => "Membership"
  )
  tag.save
  {
    "ID" => @membership_id
  }.each_pair do |field, value|
    field = CapsuleCRM::CustomField.new(
      @organisation,
      :tag => tag.name,
      :label => field,
      :text => value,
      :boolean => (value == "true")
    )
    field.save
  end
end

Given /^that organisation has a directory entry$/ do
  tag = CapsuleCRM::Tag.new(
    @organisation,
    :name => "DirectoryEntry"
  )
  tag.save
  {
    "Description" => @description,
    "Homepage"    => @homepage,
    "Logo"        => @logo,
    "Thumbnail"   => @thumb,
    "Contact"     => @contact_name,
    "Phone"       => @contact_phone,
    "Email"       => @contact_email,
    "Twitter"     => @twitter,
    "Linkedin"    => @linkedin,
    "Facebook"    => @facebook,
    "Tagline"     => @tagline,
  }.each_pair do |field, value|
    field = CapsuleCRM::CustomField.new(
      @organisation,
      :tag => tag.name,
      :label => field,
      :text => value,
      :boolean => (value == "true")
    )
    field.save
  end
end

Then /^my details should be stored in that data tag$/ do
  tests = {
    "Description"   => @description.slice(0,250),
    "Description-2" => @description.slice(250,250),
    "Description-3" => @description.slice(500,250),
    "Description-4" => @description.slice(750,250),
    "Homepage"      => @homepage,
    "Logo"          => @logo,
    "Thumbnail"     => @thumb,
    "Contact"       => @contact_name,
    "Phone"         => @contact_phone,
    "Email"         => @contact_email,
    "Twitter"       => @twitter,
    "Linkedin"      => @linkedin,
    "Facebook"      => @facebook,
    "Tagline"       => @tagline,
  }.compact
  tests.each_pair do |field_name, value|
    field = @organisation.custom_fields.find{|x| x.label == field_name && x.tag == @tag.name}
    field.should be_present
    field.text.should == value
  end
end

Then /^my original details should still be stored in that data tag$/ do
  tests = {
    "Description"   => @original_description.slice(0,250),
    "Description-2" => @original_description.slice(250,250),
    "Description-3" => @original_description.slice(500,250),
    "Description-4" => @original_description.slice(750,250),
    "Homepage"      => @original_homepage,
    "Logo"          => @original_logo,
    "Thumbnail"     => @original_thumb,
    "Contact"       => @original_contact_name,
    "Phone"         => @original_contact_phone,
    "Email"         => @original_contact_email,
    "Twitter"       => @original_twitter,
    "Linkedin"      => @original_linkedin,
    "Facebook"      => @original_facebook,
    "Tagline"       => @original_tagline,
  }.compact
  tests.each_pair do |field_name, value|
    field = @organisation.custom_fields.find{|x| x.label == field_name && x.tag == @tag.name}
    field.should be_present
    field.text.should == value
  end
end
