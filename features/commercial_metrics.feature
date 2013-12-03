@vcr @timecop
Feature: Generate commercial metrics

  In order to track the success of our commercial offerings
  As a member of the commercial team
  I want to generate various important metrics for display on a dashboard
  
  Background:
    Given the following opportunities in CapsuleCRM with paid invoices in Xero:
      | stage     | likelihood | value | close_in_x_weeks | opened_x_days_ago |
      | Closed    | 100%       | 60000 | -10              | 200               |
      | Closed    | 100%       | 40000 | -30              | 300               |
      | Proposal  | 50%        | 50000 | 20               | 150               |
      | Contract  | 70%        | 30000 | 10               | 120               |
      | Lost      | 0%         | 50000 | 3                | 110               |
      | Prospect  | 10%        | 10000 | 60               | 80                |
      | Qualified | 30%        | 20000 | 40               | 70                |
      | Forecast  | 90%        | 20000 | 200              | 60                |
    And the following invoices in Xero:
      | description     | amount | paid  | raised_x_days_ago | sales code | 
      | event booking 1 | 34.99  | true  | 100               | events     |
      | event booking 2 | 34.99  | false | 100               | events     |
      | grant income 1  | 10000  | true  | 20                | grants     |
    And that it's "2013-06-01"
  
  Scenario: Total pipeline for current year
    Then the following data should be stored in the "current-year-total-pipeline" metric
    """
    120000
    """    
    When the pipeline job runs  

  Scenario: Weighted pipeline to end of financial year
    Then the following data should be stored in the "current-year-weighted-pipeline" metric
    """
    46000
    """    
    When the pipeline job runs  

  Scenario: Total Pipeline across next three years
    Then the following data should be stored in the "three-year-total-pipeline" metric
    """
    110000
    """    
    When the pipeline job runs  
    
  Scenario: Average age of opportunity on capsule
    Then the following data should be stored in the "average-opportunity-age" metric
    """
    96
    """    
    When event
  
  Scenario: Total commercial bookings in current financial year
    Then the following data should be stored in the "current-year-total-bookings" metric
    """
    60070.98
    """    
    When event

  Scenario: Total Commercial revenue recognised (Year to date)
    Then the following data should be stored in the "current-year-total-recognised" metric
    """
    60034.99
    """    
    When event

  Scenario: Total grant income revenue recognised
    Then the following data should be stored in the "current-year-grants-recognised" metric
    """
    10000
    """    
    When event

  Scenario: Total Grant income backlog
    Given we still need to work out what this is exactly