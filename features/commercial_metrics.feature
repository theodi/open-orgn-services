@vcr @timecop
Feature: Generate commercial metrics

  In order to track the success of our commercial offerings
  As a member of the commercial team
  I want to generate various important metrics for display on a dashboard
  
  Background:
    Given the following opportunities in CapsuleCRM:
      | stage     | likelihood | value | close_in_X_weeks |
      | Closed    | 100%       | 50000 | -10              | 
      | Proposal  | 50%        | 50000 | 20               | 
      | Contract  | 70%        | 30000 | 10               |
      | Lost      | 0%         | 50000 | 3                |
      | Prospect  | 10%        | 10000 | 60               |
      | Qualified | 30%        | 20000 | 40               |
      | Forecast  | 90%        | 20000 | 200              |
    And that it's "2013-06-01"
  
  Scenario: Total pipeline for current year
    Then the following data should be stored in the "current-year-total-pipeline" metric
    """
    130000
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
  