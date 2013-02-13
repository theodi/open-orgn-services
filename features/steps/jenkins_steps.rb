Given /^no builds in Jenkins are failing$/ do
  VCR.use_cassette('jenkins_success') do
    
  end
end

Given /^a build in Jenkins is failing$/ do
  VCR.use_cassette('jenkins_failing') do
    
  end
end

When /^the jenkins monitor runs$/ do
  VCR.use_cassette('jenkins_monitor') do
    JenkinsMonitor.perform
  end
end