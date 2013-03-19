Given /^that data tag has the following fields:$/ do |table|
  table.hashes.each do |row|
    row.each_pair do |key, value|      
      instance_variable_set("@organization_#{key.downcase}", value)
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
  data = {
    'active'        => @organization_active,
    'email'         => @organization_email,
    'name'          => @organisation.name,
    'description'   => @organization_description,
    'url'           => @organization_homepage,
    'product_name'  => @organization_level,
    'membership_id' => @organization_id,
  }.compact
  MyObserverClass.should_receive(:update).with(data)
end

When /^the job is run to store the membership ID back into capsule$/ do
  SaveMembershipIdInCapsule.perform(@organisation.name, @membership_id)
end

Then /^that data tag should have my new membership number set$/ do
  field = @organisation.custom_fields.find{|x| x.label == "ID" && x.tag == @tag.name}
  field.should be_present
  field.text.should == @membership_id
end