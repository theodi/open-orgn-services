@vcr @timecop @capsulecrm
Feature: Generate membership metrics

  In order to track the health of our membership model
  As a member of the commercial team
  I want to generate various important metrics for display on a dashboard
  
  Background:
    Given the following sector tags exist in CapsuleCRM:
      | name                                |
      | Charity/Not-for-Profit              |
      | Data & Information Services         |
      | Education                           |
      | Finance                             |
      | FMCG                                |
      | Healthcare                          |
      | Professional Services               |
      | Technology/Media/Telecommunications |
      | Transport/Construction/Engineering  |
      | Utilities/Oil & Gas                 |
    Given the following members exist in CapsuleCRM:
      | name        | level     | renewal_in_x_weeks | sector                              |
      | Partner 1   | partner   | 1                  | Charity/Not-for-Profit              |
      | Sponsor 1   | sponsor   | 1                  | Data & Information Services         |
      | Sponsor 2   | sponsor   | 3.9                | Education                           |
      | Member 1    | member    | 1                  | Finance                             |
      | Member 2    | member    | 4.1                | FMCG                                |
      | Member 3    | member    | 25                 | Healthcare                          |
      | Supporter 1 | supporter | 1                  | Professional Services               |
      | Supporter 2 | supporter | 12.9               | Technology/Media/Telecommunications |
      | Supporter 3 | supporter | 13.1               | Transport/Construction/Engineering  |
      | Supporter 4 | supporter | 27                 | Utilities/Oil & Gas                 |
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
  
  Scenario: Ranking of membership coverage against white space
    Then the following data should be stored in the "membership-coverage" metric
      """
      {
        "supporter" : {
          "Charity/Not-for-Profit" : 0,
          "Data & Information Services" : 0,
          "Education" : 0,
          "Finance" : 0,
          "FMCG" : 0,
          "Healthcare" : 0,
          "Professional Services" : 1,
          "Technology/Media/Telecommunications" : 1,
          "Transport/Construction/Engineering" : 1,
          "Utilities/Oil & Gas" : 1
        },
        "member" : {
          "Charity/Not-for-Profit" : 0,
          "Data & Information Services" : 0,
          "Education" : 0,
          "Finance" : 1,
          "FMCG" : 1,
          "Healthcare" : 1,
          "Professional Services" : 0,
          "Technology/Media/Telecommunications" : 0,
          "Transport/Construction/Engineering" : 0,
          "Utilities/Oil & Gas" : 0
        },
        "sponsor" : {
          "Charity/Not-for-Profit" : 0,
          "Data & Information Services" : 1,
          "Education" : 1,
          "Finance" : 0,
          "FMCG" : 0,
          "Healthcare" : 0,
          "Professional Services" : 0,
          "Technology/Media/Telecommunications" : 0,
          "Transport/Construction/Engineering" : 0,
          "Utilities/Oil & Gas" : 0
        },
        "partner" : {
          "Charity/Not-for-Profit" : 1,
          "Data & Information Services" : 0,
          "Education" : 0,
          "Finance" : 0,
          "FMCG" : 0,
          "Healthcare" : 0,
          "Professional Services" : 0,
          "Technology/Media/Telecommunications" : 0,
          "Transport/Construction/Engineering" : 0,
          "Utilities/Oil & Gas" : 0
        }
      }
      """
    When the membership coverage job runs
  
  Scenario: Number of renewals coming up in next X months
    Then the following data should be stored in the "membership-renewals" metric
      """
      {
        "4": {
          "member": 1,
          "partner": 1,
          "sponsor": 2,
          "supporter": 1
        },
        "13": {
          "member": 2,
          "partner": 1,
          "sponsor": 2,
          "supporter": 2
        },
        "26": {
          "member": 3,
          "partner": 1,
          "sponsor": 2,
          "supporter": 3
        }
      }
      """
    When the membership renewals job runs