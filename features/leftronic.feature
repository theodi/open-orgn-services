@vcr
Feature: Leftronic dashboard publishing

  In order to track our various statistics
  As a member of the tech team
  I want to push captured statistics to a Leftronic dashboard
  
  Scenario: publish a number
    Given the number 5 has been queued for publishing in the irc stat
    When the leftronic publisher runs
    Then the number 5 should be published to the leftronic irc stat
    
  Scenario: publish some HTML
    Given the HTML '<div>WAT</div>' has been queued for publishing in the build status stat
    When the leftronic publisher runs
    Then the HTML '<div>WAT</div>' should be published to the leftronic build status stat

  @timecop
  Scenario: publish the current time
    Given that it's 2013-03-04 14:54
    Then html containing '2013-03-04T14:54:00+00:00' should be stored in the time stat
    When the dashboard time publisher runs
    
  Scenario: raise an error when publishing something silly
    Given the number 5 has been queued for publishing in the irc stat
    But we are publishing a data type called 'test' instead
    When the leftronic publisher runs it should raise an error
