When(/^the membership count job runs$/) do
  MembershipCount.perform
end

Given(/^we still need to work out what this is exactly$/) do
  pending # express the regexp above with the code you wish you had
end

When(/^the membership revenue ratio job runs$/) do
  MembershipRevenueRatio.perform
end

When(/^the membership coverage job runs$/) do
  MembershipCoverage.perform
end

When(/^the membership renewals job runs$/) do
  MembershipRenewals.perform
end

When(/^the stories job runs$/) do
  MembershipStories.perform
end