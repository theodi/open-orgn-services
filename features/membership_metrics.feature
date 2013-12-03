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
      | level     | category | renewal_in_x_weeks |
      | partner   | health   | 1                  |
      | sponsor   | telecoms | 1                  |
      | sponsor   | energy   | 3.9                |
      | member    | health   | 1                  |
      | member    | telecoms | 4.1                |
      | member    | energy   | 25                 |
      | supporter | health   | 1                  |
      | supporter | telecoms | 12.9               |
      | supporter | energy   | 13.1               |
      | supporter | health   | 27                 |
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
        "partner": 0.1,
        "sponsor": 0.2,
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
        "partner": 0.1,
        "sponsor": 0.2,
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
  
  Scenario: Number of renewals coming up in next X months
    Then the following data should be stored in the "membership-renewals" metric
      """
      {
        4: {
          "partner": 1,
          "sponsor": 2,
          "member": 1,
          "supporter": 1,
        },
        13: {
          "partner": 1,
          "sponsor": 2,
          "member": 2,
          "supporter": 2,
        },
        26: {
          "partner": 1,
          "sponsor": 2,
          "member": 3,
          "supporter": 3,
        },
      }
      """
    When the membership renewals job runs
  
  Scenario: Total number of stories / use cases 
    Given we still need to work out what this is exactly
    Then the following data should be stored in the "number-of-stories" metric
      """
      10
      """
    When the stories job runs
  
  
  
  
  
  
  
  