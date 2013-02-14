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

Then /^the json should be written to a temporary file$/ do
  file = double("tempfile")
  File.should_receive(:open).with("/tmp/courses.json", "w").and_return(file)
  file.should_receive(:write).with(@json)
  file.should_receive(:close)
end

Then /^the temporary file should be rsync'd to the web server$/ do
  Kernel.should_receive(:system).with("rsync", "/tmp/courses.json", ENV['COURSES_RSYNC_PATH'])
end

Then /^the JSON document should be available at the target URL$/ do
  uri = URI(ENV['COURSES_TARGET_URL'])
  Net::HTTP.get(uri).should == @json
end