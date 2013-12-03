@vcr @timecop
Feature: Generate membership metrics

  In order to track the health of our membership model
  As a member of the commercial team
  I want to generate various important metrics for display on a dashboard
  
  Background:
    Given the following market categories exist in CapsuleCRM:
      | name     |
      | health   |
      | telecoms |
      | energy   |
    Given the following members exist in CapsuleCRM:
      | level     | category |
      | sponsor   | health   |
      | partner   | telecoms |
      | partner   | energy   |
      | member    | health   |
      | member    | telecoms |
      | member    | energy   |
      | supporter | health   |
      | supporter | telecoms |
      | supporter | energy   |
      | supporter | health   |
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
  
  Scenario: Ranking of membership coverage against white space
    Given we still need to work out what this is exactly
    Then the following data should be stored in the "membership-coverage" metric
      """
      {
        "health": 0.33,
        "telecoms": 0.33,
        "energy": 0.33,
      }
      """
    When the membership coverage job runs
  
  
  
  
  
  