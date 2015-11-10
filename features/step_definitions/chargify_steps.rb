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
  @email = ENV['FINANCE_EMAIL']
  @reporter = ChargifyReportGenerator.new(@email, start_date, end_date)
  @reporter.fetch_data
end

Then(/^data for the cash report should match:$/) do |table|
  report = @reporter.reports["cash-report.csv"]
  table.diff!(CSV.parse(report))
end

Then(/^data for the booking value report should match:$/) do |table|
  report = @reporter.reports["booking-value-report.csv"]
  table.diff!(CSV.parse(report))
end

When(/^the job is triggered$/) do
  @reporter.send_report
end

Then(/^finance should receive an email with subject "(.*?)"$/) do |subject|
  emails = unread_emails_for(@email).select { |m| m.subject =~ Regexp.new(Regexp.escape(subject)) }
  expect(emails.size).to eq(1)
  open_email(@email, with_subject: subject)
end

Then(/^the email from "(.*?)" envar is used$/) do |var|
  @email = ENV.fetch(var)
end

Then(/^the start_date is "(#{DATE})"$/) do |start_date|
  @start_date = start_date
end

Then(/^the end_date is "(#{DATE})"$/) do |end_date|
  @end_date = end_date
end

When(/^the ChargifyReportGenerator job is performed$/) do
  reporter = double("ChargifyReportGenerator")
  expect(ChargifyReportGenerator).to receive(:new).with(@email, @start_date, @end_date).and_return(reporter)
  expect(reporter).to receive(:fetch_data)
  expect(reporter).to receive(:send_report)
  ChargifyReportGenerator.perform
end
