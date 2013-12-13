@vcr @timecop @capsulecrm @clean_up_xero_contact
Feature: Generate commercial metrics

  In order to track the success of our commercial offerings
  As a member of the commercial team
  I want to generate various important metrics for display on a dashboard
  
  Background:
    Given that it's 2013-06-01 14:00
    And the following opportunities exist in CapsuleCRM with paid invoices in Xero if closed:
      | organisation | stage     | likelihood | value | duration | close_in_x_weeks | opened_x_days_ago |
      | company A    | Invoiced  | 100%       | 60000 | 1        | -10              | 200               |
      | company B    | Invoiced  | 100%       | 40000 | 2        | -30              | 300               |
      | company C    | Proposal  | 50%        | 50000 | 3        | 20               | 150               |
      | company D    | Contract  | 70%        | 30000 | 3        | 10               | 120               |
      | company E    | Lost      | 0%         | 50000 | 2        | 3                | 110               |
      | company F    | Prospect  | 10%        | 10000 | 1        | 60               | 80                |
      | company G    | Qualified | 30%        | 20000 | 2        | 40               | 70                |
      | company H    | Forecast  | 90%        | 20000 | 3        | 200              | 60                |
  #   And the following invoices in Xero:
  #     | organisation | description     | amount | paid  | raised_x_days_ago | sales_code | 
  #     | company I    | event booking 1 | 34.99  | true  | 100               | events     |
  #     | company J    | event booking 2 | 34.99  | false | 100               | events     |
  #     | foundation A | grant income 1  | 10000  | true  | 20                | grants     |
  # 
  Scenario: Total pipeline for current year and next three years
    Then the following data should be stored in the "total-pipeline" metric
    """
    {
      "2013-01-01/2013-12-31": 120000,
      "2013-01-01/2015-12-31": 110000
    }
    """    
    When the pipeline job runs
  
  Scenario: Weighted pipeline
    Then the following data should be stored in the "weighted-pipeline" metric
    """
    {
      "2013-01-01/2013-12-31": 46000,
      "2013-01-01/2015-12-31": 53000
    }
    """    
    When the pipeline job runs
    
  Scenario: Average age of opportunity on capsule
    Then the following data should be stored in the "average-opportunity-age" metric
    """
    96
    """    
    When the opportunity age monitor job runs
  
  Scenario: Count old opportunities on capsule
    Then the following data should be stored in the "old-opportunity-count" metric
    """
    2
    """    
    When the opportunity age monitor job runs

  Scenario: Email about old opportunities
    When the opportunity reminder job runs
    Then "tech@theodi.org" should receive an email with subject "Old opportunity reminder: 150 days old"
    And "tech@theodi.org" should receive an email with subject "Old opportunity reminder: 120 days old"
    When I open the email with subject "Old opportunity reminder: 150 days old"
    And I should see /http://theodi.capsulecrm.com/opportunity/[0-9]+\./ in the email body
    Then I should see "company C" in the email body
    When I open the email with subject "Old opportunity reminder: 120 days old"
    And I should see /http://theodi.capsulecrm.com/opportunity/[0-9]+\./ in the email body
    Then I should see "company D" in the email body

  # Scenario: Total commercial bookings in current financial year
  #   Then the following data should be stored in the "current-year-total-bookings" metric
  #   """
  #   60070.98
  #   """    
  #   When the commercial bookings job runs
  #
  # Scenario: Total grant income revenue recognised
  #   Then the following data should be stored in the "current-year-grants-recognised" metric
  #   """
  #   10000
  #   """    
  #   When the grant income recognised job runs
  # 
  # Scenario: Total Grant income backlog
  #   Given we still need to work out what this is exactly
  #   When the grant income backlog job runs