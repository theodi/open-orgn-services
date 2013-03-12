Given /^my organisation name is "(.*?)"$/ do |name|
  @name = name
end

Given /^my description is "(.*?)"$/ do |description|
  @description = description
end

Given /^my organisation homepage is "(.*?)"$/ do |url|
  @url = url
end

Given /^my organisation logo is stored at "(.*?)"$/ do |logo|
  @logo = logo
end

When /^I enter my organisation details$/ do
  organization = {
      'name'        => @name
  }
  directory_entry = {
      'description' => @description,
      'url'         => @url,
      'logo'        => @logo
  }
  
  SendDirectoryEntryToCapsule.perform(organization, directory_entry)
end

Then /^my directory entry should be requeued for later processing once the contact has synced from Xero$/ do
  organization = {
      'name'        => @name
  }
  directory_entry = {
      'description' => @description,
      'url'         => @url,
      'logo'        => @logo
  }
  Resque.should_receive(:enqueue_in).with(1.hour, SendDirectoryEntryToCapsule, organization, directory_entry).once
end

Then /^that data tag should have a description "(.*?)"$/ do |description|
  field = @organisation.custom_fields.find{|x| x.label == "Description" && x.tag == @tag.name}
  field.should be_present
  field.text.should == description
end

Then /^that data tag should have an organisation url "(.*?)"$/ do |url|
  field = @organisation.custom_fields.find{|x| x.label == "Url" && x.tag == @tag.name}
  field.should be_present
  field.text.should == url
end

Then /^that data tag should have a logo url of "(.*?)"$/ do |logo|
  field = @organisation.custom_fields.find{|x| x.label == "Logo" && x.tag == @tag.name}
  field.should be_present
  field.text.should == logo
end