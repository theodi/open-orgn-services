Given /^my organisation name is "(.*?)"$/ do |name|
  @name = name
end

Given /^my description is "(.*?)"$/ do |description|
  @description = description
end

Given /^my organisation homepage is "(.*?)"$/ do |homepage|
  @homepage = homepage
end

Given /^my organisation logo \(original\) is stored at "(.*?)"$/ do |logo|
  @logo = logo
end

Given /^my organisation logo \(thumbnail\) is stored at "(.*?)"$/ do |thumb|
  @thumb = thumb
end

When /^I enter my organisation details$/ do
  organization = {
      'name'        => @name
  }
  directory_entry = {
      'description' => @description,
      'homepage'    => @homepage,
      'logo'        => @logo,
      'thumbnail'   => @thumb
  }
  
  SendDirectoryEntryToCapsule.perform(organization, directory_entry)
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
  Resque.should_receive(:enqueue_in).with(1.hour, SendDirectoryEntryToCapsule, organization, directory_entry).once
end

Then /^that data tag should have a description "(.*?)"$/ do |description|
  field = @organisation.custom_fields.find{|x| x.label == "Description" && x.tag == @tag.name}
  field.should be_present
  field.text.should == description
end

Then /^that data tag should have an organisation homepage "(.*?)"$/ do |homepage|
  field = @organisation.custom_fields.find{|x| x.label == "Homepage" && x.tag == @tag.name}
  field.should be_present
  field.text.should == homepage
end

Then /^that data tag should have a logo url of "(.*?)"$/ do |logo|
  field = @organisation.custom_fields.find{|x| x.label == "Logo" && x.tag == @tag.name}
  field.should be_present
  field.text.should == logo
end

Then /^that data tag should have a thumbnail url of "(.*?)"$/ do |thumb|
  field = @organisation.custom_fields.find{|x| x.label == "Thumbnail" && x.tag == @tag.name}
  field.should be_present
  field.text.should == thumb
end