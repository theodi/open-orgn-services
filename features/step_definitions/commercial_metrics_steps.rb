When(/^the opportunity age monitor job runs$/) do
  OpportunityAgeMonitor.perform
end

When(/^the opportunity reminder job runs$/) do
  SendOpportunityReminders.perform
end

When(/^the pipeline job runs$/) do
  PipelineMetrics.perform
end