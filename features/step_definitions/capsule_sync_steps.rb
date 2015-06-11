Given /^that data tag has the following fields:$/ do |table|
  table.hashes.each do |row|
    row.each_pair do |key, value|
      if @organisation
        instance_variable_set("@organisation_#{@tag.name.downcase}_#{key.downcase.delete('-')}", value)
      else
        instance_variable_set("@person_#{@tag.name.downcase}_#{key.downcase.delete('-')}", value)
      end
      field = CapsuleCRM::CustomField.new(
        (@organisation || @person),
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

Then /^that (organisation|person) should be queued for sync$/ do |target|
  type = instance_variable_get("@#{target}")
  Resque.should_receive(:enqueue).with(SyncCapsuleData, type.id, target.titleize)
  Resque.should_receive(:enqueue).any_number_of_times
end

Then /^that (organisation|person) should not be queued for sync$/ do |target|
  type = instance_variable_get("@#{target}")
  Resque.should_not_receive(:enqueue).with(SyncCapsuleData, type.id, target.titleize)
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

When /^the capsule sync job for that (person|organisation) runs$/ do |target|
  SyncCapsuleData.perform(instance_variable_get("@#{target}").id, target)
end

Then /^the observer should be notified with the (organisation|person)'s information$/ do |target|
  membership = {
    'email'         => instance_variable_get("@#{target}_membership_email"),
    'product_name'  => instance_variable_get("@#{target}_membership_level"),
    'id'            => instance_variable_get("@#{target}_membership_id"),
    'newsletter'    => (instance_variable_get("@#{target}_membership_newsletter") == 'true'),
    'size'          => instance_variable_get("@#{target}_membership_size"),
    'sector'        => instance_variable_get("@#{target}_membership_sector")
  }.compact
  description = [
    instance_variable_get("@#{target}_directoryentry_description"),
    instance_variable_get("@#{target}_directoryentry_description2"),
    instance_variable_get("@#{target}_directoryentry_description3"),
    instance_variable_get("@#{target}_directoryentry_description4")
  ].compact.join
  directory_entry = {
    'active'        => instance_variable_get("@#{target}_directoryentry_active"),
    'name'          => instance_variable_get("@#{target}").respond_to?(:name) ? instance_variable_get("@#{target}").name : nil ,
    'description'   => description.present? ? description : nil,
    'url'           => instance_variable_get("@#{target}_directoryentry_homepage"),
    'contact'       => instance_variable_get("@#{target}_directoryentry_contact"),
    'phone'         => instance_variable_get("@#{target}_directoryentry_phone"),
    'email'         => instance_variable_get("@#{target}_directoryentry_email"),
    'twitter'       => instance_variable_get("@#{target}_directoryentry_twitter"),
    'linkedin'      => instance_variable_get("@#{target}_directoryentry_linkedin"),
    'facebook'      => instance_variable_get("@#{target}_directoryentry_facebook"),
    'tagline'       => instance_variable_get("@#{target}_directoryentry_tagline"),
  }.compact

  MyObserverClass.should_receive(:update).with(membership, directory_entry, instance_variable_get("@#{target}").id)
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
  SaveMembershipDetailsToCapsule.perform(@organisation_membership_id, {
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
