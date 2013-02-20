@vcr
Feature: Jenkins monitoring

  In order to track our build status
  As a member of the tech team
  I want to capture current status from Jenkins and push it to a dashboard
  
  Scenario: passing builds
    Given no builds in Jenkins are failing
    Then html containing 'background-color:green' should be stored in the build status stat
    When the jenkins monitor runs
    
  Scenario: failing builds
    Given a build in Jenkins is failing
    Then html containing 'background-color:red' should be stored in the build status stat
    When the jenkins monitor runs