@vcr
Feature: Email a report to finance

  In order to keep track of revenue from membership signups
  As finance
  I need a report about monthly signups for each membership tier
  And a report about booking value for the month
  And information on any money that has been refunded

  Background:

    Given the chargify environment variables are set
    When I want to run the report for 2015-03-01 to 2015-03-31

  Scenario: Report the transactions and the end of the month

    Then it should email a report to 'finance@theodi.org'
    And attach a cash_report.csv
    And attach a booking_value_report.csv

  Scenario: the cash report contains the correct data

    Then data for the cash report should match:

     | date                | membership number | statement id | membership type             | transaction type | amount | tax  | total |
     | 2015-03-02 11:36:05 | XK4240RD          | 47700918     | individual-supporter        | payment          | 90     | 18   | 108   |
     | 2015-03-02 11:56:58 | MEMNUM0           | 47701405     | individual-supporter        | payment          | 90     | 18   | 108   |
     | 2015-03-04 10:36:57 | YV8920WD          | 47813535     | individual-supporter        | payment          | 90     | 18   | 108   |
     | 2015-03-04 10:42:59 | DV3064BO          | 47813975     | individual-supporter        | payment          | 90     | 18   | 108   |
     | 2015-03-04 11:23:29 | WI8347MG          | 47815044     | corporate-supporter_annual  | payment          | 2200   | 440  | 2640  |
     | 2015-03-04 11:34:29 | JD6183RS          | 47815091     | supporter_annual            | payment          | 720    | 144  | 864   |
     | 2015-03-06 14:16:13 | ST0665UQ          | 48051286     | supporter_annual            | payment          | 720    | 144  | 864   |
     | 2015-03-06 14:35:21 | ST0665UQ          | 48052021     | supporter_annual            | refund           | -720   | -144 | -864  |
     | 2015-03-09 14:52:33 | RO8859CT          | 48175665     | supporter_monthly           | payment          | 60     | 12   | 72    |
     | 2015-03-09 14:55:20 | YD9737TJ          | 48175697     | corporate-supporter_annual  | payment          | 2200   | 440  | 2640  |
     | 2015-03-10 12:14:23 | KM3941LD          | 48214914     | supporter_annual            | payment          | 720    | 144  | 864   |
     | 2015-03-10 14:21:40 | MEMNUM3           | 48219026     | individual-supporter        | payment          | 90     | 18   | 108   |
     |                     |                   |              |                             | totals           | 6350   | 1270 | 7620  |

  Scenario: the booking value report contains the correct data

    Then data for the booking value report should match:

      | product name               | signup count | booking value | net  | tax | total |
      | individual-supporter       | 5            | 90            | 450  | 90  | 540   |
      | supporter_annual           | 3            | 720           | 2160 | 432 | 2592  |
      | corporate-supporter_annual | 2            | 2200          | 4400 | 880 | 5280  |
      | supporter_monthly          | 1            | 720           | 720  | 144 | 864   |
