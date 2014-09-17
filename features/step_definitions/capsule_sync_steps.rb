Given /^that data tag has the following fields:$/ do |table|
  table.hashes.each do |row|
    row.each_pair do |key, value|      
      instance_variable_set("@organization_#{@tag.name.downcase}_#{key.downcase.delete('-')}", value)
      field = CapsuleCRM::CustomField.new(
        @organisation,
        :tag => @tag.name,
        :label => key,
        :text => value,
        :boolean => (value == "true")
      )
      field.save
    end
  end
end

Given /^a membership has been created for me$/ do
  @membership_id = "AB6543GF"
end

Then /^that organisation should be queued for sync$/ do
  Resque.should_receive(:enqueue).with(SyncCapsuleData, @organisation.id)
end

Then /^that organisation should not be queued for sync$/ do
  Resque.should_not_receive(:enqueue).with(SyncCapsuleData, @organisation.id)
end

When /^the capsule monitor runs$/ do
  CapsuleSyncMonitor.perform
end

class MyObserverClass
  def self.register
    SyncCapsuleData.add_observer(self)
  end
  def self.update(data)
  end
end

Given /^an observer object has been registered$/ do
  MyObserverClass.register
end

When /^the capsule sync job for that organisation runs$/ do
  SyncCapsuleData.perform(@organisation.id)
end

Then /^the observer should be notified with the organisation's information$/ do
  membership = {
    'email'         => @organization_membership_email,
    'product_name'  => @organization_membership_level,
    'id'            => @organization_membership_id,      
    'newsletter'    => (@organization_membership_newsletter == 'true'),
  }.compact
  description = [
    @organization_directoryentry_description,
    @organization_directoryentry_description2,
    @organization_directoryentry_description3,
    @organization_directoryentry_description4
  ].compact.join
  directory_entry = {
    'active'        => @organization_directoryentry_active,
    'name'          => @organisation.name,
    'description'   => description.present? ? description : nil,
    'url'           => @organization_directoryentry_homepage,
    'contact'       => @organization_directoryentry_contact,
    'phone'         => @organization_directoryentry_phone,
    'email'         => @organization_directoryentry_email,
    'twitter'       => @organization_directoryentry_twitter,
    'linkedin'      => @organization_directoryentry_linkedin,
    'facebook'      => @organization_directoryentry_facebook,      
    'tagline'       => @organization_directoryentry_tagline,
  }.compact
  MyObserverClass.should_receive(:update).with(membership, directory_entry, @organisation.id)
end

When /^the job is run to store the membership ID back into capsule$/ do
  SaveMembershipIdInCapsule.perform(@organisation.name, @membership_id)
end

Then /^that data tag should have my new membership number set$/ do
  field = @organisation.custom_fields.find{|x| x.label == "ID" && x.tag == @tag.name}
  field.should be_present
  field.text.should == @membership_id
end

# Store membership details

Given /^I have updated my membership details$/ do
  @updated_email = 'contact@weyland-yutani.com'
  @updated_newsletter = true
  @updated_size = '<10'
  @updated_sector = 'Other'
end

When /^the job is run to update my membership details in capsule$/ do
  SaveMembershipDetailsToCapsule.perform(@organization_membership_id, {
    'email'      => @updated_email,
    'newsletter' => @updated_newsletter,
    'size'       => @updated_size,
    'sector'     => @updated_sector
  })
end

Then /^that data tag should have my updated email$/ do
  field = @organisation.custom_fields.find{|x| x.label == "Email" && x.tag == @tag.name}
  field.should be_present
  field.text.should == @updated_email
end

Then /^that data tag should have my updated newsletter preferences$/ do
  field = @organisation.custom_fields.find{|x| x.label == "Newsletter" && x.tag == @tag.name}
  field.should be_present
  field.boolean.should == @updated_newsletter
end

Then(/^that data tag should have my updated size$/) do
  field = @organisation.custom_fields.find{|x| x.label == "Size" && x.tag == @tag.name}
  field.should be_present
  field.text.should == @updated_size
end

Then(/^that data tag should have my updated sector$/) do
  field = @organisation.custom_fields.find{|x| x.label == "Sector" && x.tag == @tag.name}
  field.should be_present
  field.text.should == @updated_sector
end