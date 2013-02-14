Then /^the event summary generator should be queued$/ do
  Resque.should_receive(:enqueue).with(EventSummaryGenerator, @events).once
  Resque.should_receive(:enqueue).any_number_of_times
end

Then /^the summary uploader should be queued with the following JSON:$/ do |json|
  Resque.should_receive(:enqueue).with(EventSummaryUploader, json).once
end

When /^the event summary generator is run$/ do
  EventSummaryGenerator.perform(@events)
end

Given /^a JSON document like this:$/ do |json|
  @json = json
end

When /^the summary uploader runs$/ do
  EventSummaryUploader.perform(@json)
end

Then /^the JSON document should be available at the target URL$/ do
  pending # express the regexp above with the code you wish you had
end