@vcr @timecop @capsulecrm
Feature: Generate membership metrics

  In order to track the health of our membership model
  As a member of the commercial team
  I want to generate various important metrics for display on a dashboard
  
  Background:
    Given the following sectors exist in CapsuleCRM:
      | name     |
      | health   |
      | telecoms |
      | energy   |
    Given the following members exist in CapsuleCRM:
      | name        | level     | sector   | renewal_in_x_weeks |
      | Partner 1   | partner   | health   | 1                  |
      | Sponsor 1   | sponsor   | telecoms | 1                  |
      | Sponsor 2   | sponsor   | energy   | 3.9                |
      | Member 1    | member    | health   | 1                  |
      | Member 2    | member    | telecoms | 4.1                |
      | Member 3    | member    | energy   | 25                 |
      | Supporter 1 | supporter | health   | 1                  |
      | Supporter 2 | supporter | telecoms | 12.9               |
      | Supporter 3 | supporter | energy   | 13.1               |
      | Supporter 4 | supporter | health   | 27                 |
    And that time is frozen
  
  Scenario: Members at each level
    Then the following data should be stored in the "membership-count" metric
      """
      {
        "total": 10,
        "by_level": {
          "member": 3,
          "partner": 1,
          "sponsor": 2,
          "supporter": 4
        }
      }
      """
    When the membership count job runs
    
  # Scenario: Member revenue income ratio
  #   Given we still need to work out what this is exactly
  #   Then the following data should be stored in the "membership-revenue-ratio" metric
  #     """
  #     {
  #       "partner": 0.1,
  #       "sponsor": 0.2,
  #       "member": 0.3,
  #       "supporter": 0.4,
  #     }
  #     """
  #   When the membership revenue ratio job runs
  
  # Scenario: Ranking of membership coverage against white space
  #   Given we still need to work out what this is exactly
  #   Then the following data should be stored in the "membership-coverage" metric
  #     """
  #     {
  #       "health": 0.33,
  #       "telecoms": 0.33,
  #       "energy": 0.33,
  #     }
  #     """
  #   When the membership coverage job runs
  
  # Scenario: Number of renewals coming up in next X months
  #   Then the following data should be stored in the "membership-renewals" metric
  #     """
  #     {
  #       4: {
  #         "member": 1,
  #         "partner": 1,
  #         "sponsor": 2,
  #         "supporter": 1,
  #       },
  #       13: {
  #         "member": 2,
  #         "partner": 1,
  #         "sponsor": 2,
  #         "supporter": 2,
  #       },
  #       26: {
  #         "member": 3,
  #         "partner": 1,
  #         "sponsor": 2,
  #         "supporter": 3,
  #       },
  #     }
  #     """
  #   When the membership renewals job runs