Given(/^the following events exist:$/) do |events|
  @events ||= []
  events.hashes.each do |event|
    event['location'].blank? ? event['location'] = nil : event['location'] = event['location']
    event['live'] = true
    event['starts_at'] = DateTime.parse(event['starts_at']).to_s
    event['ends_at'] = DateTime.parse(event['ends_at']).to_s
    event['capacity'] = event['capacity'].to_i
    @events << event.compact
  end
end

Given(/^the events have the following ticket types:$/) do |tickets|
  @events.each do |event|
    event['ticket_types'] = []
    tickets.hashes.each do |ticket|
      if event['id'] == ticket['event_id']
        starts_at = DateTime.parse(ticket['starts_at']).to_s rescue nil
        event['ticket_types'] << {
              'remaining' => ticket['tickets'].to_i,
              'name'      => ticket['name'],
              'price'     => Float(ticket['price']),
              'currency'  => ticket['currency'],
              'ends_at'   => DateTime.parse(ticket['ends_at']).to_s,
              'starts_at' => starts_at
          }.compact
      end
    end
  end  
end

Then /^the event summary generator should be queued$/ do
  Resque.stub(:enqueue)
  Resque.should_receive(:enqueue).with(EventSummaryGenerator, @events).once
end

Then /^the courses summary uploader should be queued with the following JSON:$/ do |json|
  Resque.should_receive(:enqueue).with(EventSummaryUploader, json, "courses").once
end

Then /^the lectures summary uploader should be queued with the following JSON:$/ do |json|
  Resque.should_receive(:enqueue).with(EventSummaryUploader, json, "lectures").once
end

When /^the event summary generator is run$/ do
  EventSummaryGenerator.perform(@events)
end

Given /^a JSON document like this:$/ do |json|
  @json = json
end

When /^the summary uploader runs$/ do
  EventSummaryUploader.perform(@json, "courses")
end

Then /^the JSON document should be available at the target URL$/ do
  uri = URI(ENV['COURSES_TARGET_URL'])
  expect(Net::HTTP.get(uri)).to eq(@json)
end
