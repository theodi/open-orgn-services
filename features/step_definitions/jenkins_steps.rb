Given /^no builds in Jenkins are failing$/ do
end

Given /^a build in Jenkins is failing$/ do
end

When /^the jenkins monitor runs$/ do
  BuildStatusMonitor.perform
end