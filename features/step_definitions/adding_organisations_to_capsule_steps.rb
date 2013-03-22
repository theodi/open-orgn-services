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

Given /^the date and time is (#{DATETIME})$/ do |date|
  @date = date.to_s
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
  
  Resque.should_receive(:enqueue_in).with(1.hour, SendDirectoryEntryToCapsule, @membership_id, organization, directory_entry, date).once
end

Given /^there is an existing organisation in CapsuleCRM called "(.*?)" with a data tag$/ do |organisation_name|
  CapsuleCRM::Organisation.find_all(:q => organisation_name).should be_empty
  @organisation = CapsuleCRM::Organisation.new(:name => organisation_name)
  @organisation.save
  @capsule_cleanup << @organisation
  CapsuleCRM::Organisation.find_all(:q => organisation_name).should_not be_empty
  
  # I'm not at all sure about this. This seems to be using our code to 
  # set up preconditions for our testing of our own code.
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

Given /^the organisation was updated on (#{DATETIME})$/ do |datetime|
  Timecop.freeze(datetime) do
    organisation = CapsuleCRM::Organisation.new(:name => @name)
    organisation.save
    @capsule_cleanup << organisation
  end
end

Then /^my details should be stored in that data tag$/ do
  tests = {
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
  }
  tests.each_pair do |field_name, value|
    field = @organisation.custom_fields.find{|x| x.label == field_name && x.tag == @tag.name}
    field.should be_present
    field.text.should == value
  end
end

Then /^my original details should still be stored in that data tag$/ do
  tests = {
    "Description" => @original_description,
    "Homepage"    => @original_homepage,
    "Logo"        => @original_logo,
    "Thumbnail"   => @original_thumb,
    "Contact"     => @original_contact_name,
    "Phone"       => @original_contact_phone,
    "Email"       => @original_contact_email,
    "Twitter"     => @original_twitter,
    "Linkedin"    => @original_linkedin,
    "Facebook"    => @original_facebook,
    "Tagline"     => @original_tagline,
  }
  tests.each_pair do |field_name, value|
    field = @organisation.custom_fields.find{|x| x.label == field_name && x.tag == @tag.name}
    field.should be_present
    field.text.should == value
  end
end