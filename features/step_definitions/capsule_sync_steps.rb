Then /^that organisation should be queued for sync$/ do
  Resque.should_receive(:enqueue).with(SyncCapsuleData, @organisation.id)
end

Then /^that organisation should not be queued for sync$/ do
  Resque.should_not_receive(:enqueue).with(SyncCapsuleData, @organisation.id)
end

When /^the capsule monitor runs$/ do
  CapsuleSyncMonitor.perform
end