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
    When the job is triggered
    Then finance should receive an email with subject "Membership finance report for March 2015"
    And there should be an attachment named "cash-report.csv"
    And there should be an attachment named "booking-value-report.csv"

  Scenario: the cash report contains the correct data
    Then data for the cash report should match:

      | date                | membership number | statement id | membership type             | transaction type | coupon | original net price | discount | tax  | total |
      | 2015-03-02 11:36:05 | XK4240RD          | 47700918     | individual-supporter        | payment          |        | 90                 | 0        | 18   | 108   |
      | 2015-03-02 11:56:58 | MEMNUM0           | 47701405     | individual-supporter        | payment          |        | 90                 | 0        | 18   | 108   |
      | 2015-03-04 10:36:57 | YV8920WD          | 47813535     | individual-supporter        | payment          |        | 90                 | 0        | 18   | 108   |
      | 2015-03-04 10:42:59 | DV3064BO          | 47813975     | individual-supporter        | payment          |        | 90                 | 0        | 18   | 108   |
      | 2015-03-04 11:23:29 | WI8347MG          | 47815044     | corporate-supporter_annual  | payment          |        | 2200               | 0        | 440  | 2640  |
      | 2015-03-04 11:34:29 | JD6183RS          | 47815091     | supporter_annual            | payment          |        | 720                | 0        | 144  | 864   |
      | 2015-03-06 14:16:13 | ST0665UQ          | 48051286     | supporter_annual            | payment          |        | 720                | 0        | 144  | 864   |
      | 2015-03-06 14:35:21 | ST0665UQ          | 48052021     | supporter_annual            | refund           |        | -720               | 0        | -144 | -864  |
      | 2015-03-09 14:52:33 | RO8859CT          | 48175665     | supporter_monthly           | payment          |        | 60                 | 0        | 12   | 72    |
      | 2015-03-09 14:55:20 | YD9737TJ          | 48175697     | corporate-supporter_annual  | payment          |        | 2200               | 0        | 440  | 2640  |
      | 2015-03-10 12:14:23 | KM3941LD          | 48214914     | supporter_annual            | payment          |        | 720                | 0        | 144  | 864   |
      | 2015-03-10 14:21:40 | MEMNUM3           | 48219026     | individual-supporter        | payment          |        | 90                 | 0        | 18   | 108   |
      |                     |                   |              |                             |                  | totals | 6350               | 0        | 1270 | 7620  |

  Scenario: the booking value report contains the correct data
    Then data for the booking value report should match:

      | product name               | signup count | booking value | net  | tax | total |
      | individual-supporter       | 5            | 90            | 450  | 90  | 540   |
      | supporter_annual           | 3            | 720           | 2160 | 432 | 2592  |
      | corporate-supporter_annual | 2            | 2200          | 4400 | 880 | 5280  |
      | supporter_monthly          | 1            | 720           | 720  | 144 | 864   |

  Scenario: the cash report with coupon adjustments contains the correct data
    When I want to run the report for 2015-02-20 to 2015-02-21
    Then data for the cash report should match:

      | date                | membership number | statement id | membership type            | transaction type | coupon    | original net price | discount | tax | total |
      | 2015-02-20 11:48:49 | HC2362FT          | 47125224     | individual-supporter       | payment          |           | 90                 | 0        | 0   | 90    |
      | 2015-02-20 11:58:58 | II3980RK          | 47125255     | individual-supporter       | payment          | SUPERFREE | 90                 | -90      | 0   | 0     |
      | 2015-02-20 12:07:19 | NK2275JC          | 47125709     | supporter_annual           | payment          |           | 720                | 0        | 0   | 720   |
      | 2015-02-20 12:18:40 | AD0597TT          | 47125774     | corporate-supporter_annual | payment          |           | 2200               | 0        | 440 | 2640  |
      | 2015-02-20 14:15:48 | ZT1079FY          | 47128978     | corporate-supporter_annual | payment          |           | 2200               | 0        | 440 | 2640  |
      | 2015-02-20 17:06:16 |                   | 47136873     | individual-supporter       | payment          |           | 90                 | 0        | 18  | 108   |
      |                     |                   |              |                            |                  | totals    | 5390               | -90      | 898 | 6198  |

