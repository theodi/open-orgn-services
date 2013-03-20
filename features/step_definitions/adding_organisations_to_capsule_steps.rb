Given /^I enter my organisation details$/ do
  @name        = "The RAND Corporation"
  @description = "Lorem ipsum dolor sit amet, consectetur adipiscing elit."
  @homepage    = "http://www.example.com"
  @logo        = "http://stuff.theodi.org/images/acmelogo.png"
  @thumb       = "http://stuff.theodi.org/images/thumbs/acmelogo.png"
end

Given /^I change my organisation details$/ do
  # Store old details
  @original_name        = @name        
  @original_description = @description 
  @original_homepage    = @homepage    
  @original_logo        = @logo        
  @original_thumb       = @thumb       
  # Update details  
  @name        = "The RAND Corporation"
  @description = "Bacon ipsum dolor sit amet pig strip steak jerky shankle sausage prosciutto"
  @homepage    = "http://www.example.com/homepage"
  @logo        = "http://stuff.theodi.org/images/acmelogo_new.png"
  @thumb       = "http://stuff.theodi.org/images/thumbs/acmelogo_new.png"
end

Given /^my organisation name is "(.*?)"$/ do |name|
  @original_name = @name
  @name = name
end

Given /^my description is "(.*?)"$/ do |description|
  @original_description = @description
  @description = description
end

Given /^my organisation homepage is "(.*?)"$/ do |homepage|
  @original_homepage = @homepage
  @homepage = homepage
end

Given /^my organisation logo \(original\) is stored at "(.*?)"$/ do |logo|
  @original_logo = @logo
  @logo = logo
end

Given /^my organisation logo \(thumbnail\) is stored at "(.*?)"$/ do |thumb|
  @original_thumb = @thumb
  @thumb = thumb
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
      'thumbnail'   => @thumb
  }
  date = DateTime.now.to_s
  
  SendDirectoryEntryToCapsule.perform(organization, directory_entry, date)
end

Then /^my directory entry should be requeued for later processing once the contact has synced from Xero$/ do
  organization = {
      'name'        => @name
  }
  directory_entry = {
      'description' => @description,
      'homepage'    => @homepage,
      'logo'        => @logo,
      'thumbnail'   => @thumb
  }
  date = DateTime.now.to_s
  
  Resque.should_receive(:enqueue_in).with(1.hour, SendDirectoryEntryToCapsule, organization, directory_entry, date).once
end

Given /^there is an existing organisation in CapsuleCRM called "(.*?)" with a data tag$/ do |organisation_name|
  CapsuleCRM::Organisation.find_all(:q => organisation_name).should be_empty
  @organisation = CapsuleCRM::Organisation.new(:name => organisation_name)
  @organisation.save
  @capsule_cleanup << @organisation
  CapsuleCRM::Organisation.find_all(:q => organisation_name).should_not be_empty
  
  organization = {
      'name'        => @name
  }
  directory_entry = {
      'description' => @description,
      'homepage'    => @homepage,
      'logo'        => @logo,
      'thumbnail'   => @thumb
  }
  date = DateTime.now.to_s
  
  SendDirectoryEntryToCapsule.perform(organization, directory_entry, date)
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
  }
  tests.each_pair do |field_name, value|
    field = @organisation.custom_fields.find{|x| x.label == field_name && x.tag == @tag.name}
    field.should be_present
    field.text.should == value
  end
end