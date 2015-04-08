Feature: Report chargify income to finance@theodi.org

  @timecop
  Scenario: initiate report when the resque job is triggered

    Given that it's 2015-03-01 14:54
    And the chargify environment variables are set
    Then the email from "FINANCE_EMAIL" envar is used
    And the start_date is "2015-02-01"
    And the end_date is "2015-02-28"
    When the ChargifyReportGenerator job is performed
