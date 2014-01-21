@vcr
Feature: Consolidate Xero GDrive Exports into a single spreadsheet
  In order to get a sound overview of finance
  As a finance team member
  I want my PL exports from Xero to be consolidated into a defined Spreadsheet

  Scenario: Move the spreadsheets to the target collection
    Given there is 1 spreadsheet in the spool
    And the aggregate spreadsheet has 1 worksheet
    When the gdrive mover job runs
    Then there should be 2 spreadsheets in the target
    And there should be 0 spreadsheets in the spool
    And the aggregate spreadsheet should have 2 worksheets
    And the new worksheet should match the moved spreadsheet content
