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
    10
    """    
    When the membership count job runs
    
  Scenario: Precentage of members per level
    Then the following data should be stored in the "membership-breakdown" metric
      """
      {
        "sponsor": 0.1,
        "partner": 0.2,
        "member": 0.3,
        "supporter": 0.4,
      }
      """
    When the membership breakdown job runs
    
  Scenario: Member revenue income ratio
    Given we still need to work out what this is exactly
    Then the following data should be stored in the "membership-revenue-ratio" metric
      """
      {
        "sponsor": 0.1,
        "partner": 0.2,
        "member": 0.3,
        "supporter": 0.4,
      }
      """
    When the membership revenue ratio job runs
  
  
  
  
  