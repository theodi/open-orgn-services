Given(/^the chargify environment variables are set$/) do
  expect(ENV).to have_key('CHARGIFY_API_KEY')
  expect(ENV).to have_key('CHARGIFY_SUBDOMAIN')
  expect(ENV).to have_key('FINANCE_EMAIL')
  Chargify.configure do |c|
    c.api_key   = ENV['CHARGIFY_API_KEY']
    c.subdomain = ENV['CHARGIFY_SUBDOMAIN']
  end
end

Given(/^I want to run the report for (#{DATE}) to (#{DATE})$/) do |start_date, end_date|
  @reporter = ReportGenerator.new(start_date, end_date)
  @reporter.fetch_data
end

Then(/^data for the cash report should match:$/) do |table|
  report = @reporter.cash_report
  table.diff!(report)
end

Then(/^data for the booking value report should match:$/) do |table|
  report = @reporter.booking_value_report
  table.diff!(report)
end

