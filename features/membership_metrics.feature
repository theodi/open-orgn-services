@vcr @timecop
Feature: Generate membership metrics

  In order to track the health of our membership model
  As a member of the commercial team
  I want to generate various important metrics for display on a dashboard
  
  Background:
    Given the following members exist in CapsuleCRM:
      | level     | 
      | sponsor   |
      | partner   |
      | partner   |
      | member    |
      | member    |
      | member    |
      | supporter |
      | supporter |
      | supporter |
      | supporter |
    And that time is frozen
  
  Scenario: Total number of members
    Then the following data should be stored in the "membership-count" metric
      """
      {
        "name": "membership-count",
        "time": "<%= @time.xmlschema %>",
        "value": 10,
      }
      """
    When the membership count job runs
    
  Scenario: Precentage of members per level
    Then the following data should be stored in the "membership-breakdown" metric
      """
      {
        "name": "membership-breakdown",
        "time": "<%= @time.xmlschema %>",
        "value": {
          "sponsor": 0.1,
          "partner": 0.2,
          "member": 0.3,
          "supporter": 0.4,
        },
      }
      """
    When the membership breakdown job runs  
  
  