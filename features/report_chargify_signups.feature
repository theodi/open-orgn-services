@vcr
Feature: Email a report to finance
  In order to keep track of revenue from membership signups
  As finance
  I need a report about monthly signups for each membership tier
  And a report about booking value for the month
  And information on any money that has been refunded

  Background:
    Given the chargify environment variables are set

  Scenario: Report the transactions and the end of the month
    Given I want to run the report for 2015-03-01 to 2015-03-31
    When the job is triggered
    Then finance should receive an email with subject "Membership finance report for March 2015"
    And there should be an attachment named "cash-report.csv"
    And there should be an attachment named "booking-value-report.csv"

  Scenario: the cash report contains the correct data
    Given I want to run the report for 2015-03-01 to 2015-03-31
    Then data for the cash report should match:

      | date                | company           | membership number | statement id | membership type             | transaction type | coupon | coupon amount | original net price | discount | net after discount | tax  | total |
      | 2015-03-02 11:36:05 | Test Person       | XK4240RD          | 47700918     | individual-supporter        | payment          |        |               | 90                 | 0        | 90                 | 18   | 108   |
      | 2015-03-02 11:56:58 | test person       | MEMNUM0           | 47701405     | individual-supporter        | payment          |        |               | 90                 | 0        | 90                 | 18   | 108   |
      | 2015-03-04 10:36:57 | T P               | YV8920WD          | 47813535     | individual-supporter        | payment          |        |               | 90                 | 0        | 90                 | 18   | 108   |
      | 2015-03-04 10:42:59 | T P               | DV3064BO          | 47813975     | individual-supporter        | payment          |        |               | 90                 | 0        | 90                 | 18   | 108   |
      | 2015-03-04 11:23:29 | Test Org          | WI8347MG          | 47815044     | corporate-supporter_annual  | payment          |        |               | 2200               | 0        | 2200               | 440  | 2640  |
      | 2015-03-04 11:34:29 | Testing Org       | JD6183RS          | 47815091     | supporter_annual            | payment          |        |               | 720                | 0        | 720                | 144  | 864   |
      | 2015-03-06 14:16:13 | Zappa Records     | ST0665UQ          | 48051286     | supporter_annual            | payment          |        |               | 720                | 0        | 720                | 144  | 864   |
      | 2015-03-06 14:35:21 | Zappa Records     | ST0665UQ          | 48052021     | supporter_annual            | refund           |        |               | -720               | 0        |                    | -144 | -864  |
      | 2015-03-09 14:52:33 | Some organization | RO8859CT          | 48175665     | supporter_monthly           | payment          |        |               | 60                 | 0        | 60                 | 12   | 72    |
      | 2015-03-09 14:55:20 | Company Name      | YD9737TJ          | 48175697     | corporate-supporter_annual  | payment          |        |               | 2200               | 0        | 2200               | 440  | 2640  |
      | 2015-03-10 12:14:23 | Test Org          | KM3941LD          | 48214914     | supporter_annual            | payment          |        |               | 720                | 0        | 720                | 144  | 864   |
      | 2015-03-10 14:21:40 | T P               | MEMNUM3           | 48219026     | individual-supporter        | payment          |        |               | 90                 | 0        | 90                 | 18   | 108   |
      |                     |                   |                   |              |                             |                  | totals |               | 6350               | 0        |                    | 1270 | 7620  |

  Scenario: the cash report contains the correct data
    Given I want to run the report for 2015-09-01 to 2015-09-30
    Then data for the cash report should match:

      | date                | company                             | membership number | statement id| membership type         | transaction type | coupon      | coupon amount | original net price | discount | net after discount | tax | total |
      | 2015-09-11 16:21:21 | iGeolise                            | ED3719XS          | 57413813    | supporter_monthly       | payment          |             |               | 60                 | 0        | 60                 | 12  | 72    |
      | 2015-09-02 15:33:08 | Images&Co Ltd                       | VM9556SP          | 56968155    | supporter_legacy_annual | payment          |             |               | 540                | 0        | 540                | 0   | 540   |
      | 2015-09-07 23:01:56 | Oasis Loss Modelling Framework      | DH9645KA          | 57240140    | supporter_legacy_annual | payment          |             |               | 540                | 0        | 540                | 108 | 648   |
      | 2015-09-22 09:21:00 | Big Data Partnership                | RE2054JO          | 57887343    | supporter_monthly       | payment          |             |               | 60                 | 0        | 60                 | 12  | 72    |
      | 2015-09-01 13:01:39 | Deliver Change Ltd                  | BG2374IK          | 56931908    | supporter_monthly       | payment          |             |               | 60                 | 0        | 60                 | 12  | 72    |
      | 2015-09-15 12:01:54 | IMIN LTD                            | UJ3966SJ          | 57581240    | supporter_monthly       | payment          |             |               | 60                 | 0        | 60                 | 12  | 72    |
      | 2015-09-22 16:01:59 | Signal Noise                        | GH9206SP          | 57899184    | supporter_monthly       | payment          |             |               | 60                 | 0        | 60                 | 12  | 72    |
      | 2015-09-07 20:40:55 | Singular Intelligence Limited       | NL4014DC          | 57234271    | supporter_monthly       | payment          |             |               | 60                 | 0        | 60                 | 12  | 72    |
      | 2015-09-28 16:20:44 | Emu Analytics Limited               | TZ3130DN          | 58183839    | supporter_monthly       | payment          |             |               | 60                 | 0        | 60                 | 12  | 72    |
      | 2015-09-05 15:01:30 | GeoWise Limited                     | PZ0603JE          | 57137691    | supporter_monthly       | payment          |             |               | 60                 | 0        | 60                 | 12  | 72    |
      | 2015-09-14 10:21:04 | ESI Limited                         | ZU1679SB          | 57531564    | supporter_monthly       | payment          |             |               | 60                 | 0        | 60                 | 12  | 72    |
      | 2015-09-15 12:32:51 | Christiana Dankwa                   | WT8786FG          | 57582066    | individual-supporter    | refund           |             |               | -90                | 0        |                    | -18 | -108  |
      | 2015-09-01 12:01:52 | Design For Social Change Ltd (D4SC) | AF2083GK          | 56929639    | supporter_monthly       | payment          |             |               | 60                 | 0        | 60                 | 12  | 72    |
      | 2015-09-04 09:56:48 | Clanmil Housing Association         | AQ0201OD          | 57085528    | individual-supporter    | payment          | ODITRAINING | 100%          | 90                 | -90      | 0                  | 0   | 0     |
      | 2015-09-14 07:35:49 | Institute for Applied Informatics   | WG0685GG          | 57527632    | individual-supporter    | payment          | MENTOR      | 100%          | 90                 | -90      | 0                  | 0   | 0     |
      | 2015-09-14 07:40:02 | Wolters Kluwer Deutschland GmbH     | YN4078UF          | 57527655    | individual-supporter    | payment          | MENTOR      | 100%          | 90                 | -90      | 0                  | 0   | 0     |
      | 2015-09-14 08:25:04 | Lieven Janssen                      | BO7112XU          | 57528673    | individual-supporter    | payment          | MENTOR      | 100%          | 90                 | -90      | 0                  | 0   | 0     |
      | 2015-09-14 08:35:14 | 201010 Ltd                          | VZ6871CJ          | 57528785    | individual-supporter    | payment          | MENTOR      | 100%          | 90                 | -90      | 0                  | 0   | 0     |
      | 2015-09-14 09:20:27 | Christoph Pinkel                    | DD6238PE          | 57529892    | individual-supporter    | payment          | MENTOR      | 100%          | 90                 | -90      | 0                  | 0   | 0     |
      | 2015-09-14 09:48:37 | Interdependent Thoughts             | II8695SI          | 57530845    | individual-supporter    | payment          | MENTOR      | 100%          | 90                 | -90      | 0                  | 0   | 0     |
      | 2015-09-14 10:43:34 | Zach Beauvais                       | TR6735OJ          | 57532290    | individual-supporter    | payment          | MENTOR      | 100%          | 90                 | -90      | 0                  | 0   | 0     |
      | 2015-09-14 14:50:57 | Kate Northstone                     | UB4712EG          | 57539667    | individual-supporter    | payment          | ODITRAINING | 100%          | 90                 | -90      | 0                  | 0   | 0     |
      | 2015-09-15 20:06:31 | Niels Erik Kaaber Rasmussen         | HV7343ZD          | 57601748    | individual-supporter    | payment          | MENTOR      | 100%          | 90                 | -90      | 0                  | 0   | 0     |
      | 2015-09-16 15:24:39 | University of Milano Bicocca        | WP2222EE          | 57638251    | individual-supporter    | payment          | MENTOR      | 100%          | 90                 | -90      | 0                  | 0   | 0     |
      | 2015-09-16 15:45:35 | emapsite                            | DW1850JL          | 57638980    | individual-supporter    | payment          | ODITRAINING | 100%          | 90                 | -90      | 0                  | 0   | 0     |
      | 2015-09-18 07:46:18 | Daniel Rudmark                      | EX3510UH          | 57717841    | individual-supporter    | payment          | MENTOR      | 100%          | 90                 | -90      | 0                  | 0   | 0     |
      | 2015-09-18 13:38:24 | Carl Rodrigues                      | TP5921MO          | 57725195    | individual-supporter    | payment          | MENTOR      | 100%          | 90                 | -90      | 0                  | 0   | 0     |
      | 2015-09-19 19:04:21 | Empolis                             | AH3305JS          | 57777465    | individual-supporter    | payment          | MENTOR      | 100%          | 90                 | -90      | 0                  | 0   | 0     |
      | 2015-09-21 06:11:07 | British Telecom                     | KJ7341EC          | 57838985    | individual-supporter    | payment          | MENTOR      | 100%          | 90                 | -90      | 0                  | 0   | 0     |
      | 2015-09-24 13:18:45 | CABI                                | GG8714TK          | 57989237    | individual-supporter    | payment          | ODITRAINING | 100%          | 90                 | -90      | 0                  | 0   | 0     |
      | 2015-09-24 13:21:02 | CAB International                   | MK2889FR          | 57989343    | individual-supporter    | payment          | ODITRAINING | 100%          | 90                 | -90      | 0                  | 0   | 0     |
      | 2015-09-24 13:27:59 | CABI                                | IW1257LR          | 57989719    | individual-supporter    | payment          | ODITRAINING | 100%          | 90                 | -90      | 0                  | 0   | 0     |
      | 2015-09-24 14:04:16 | CAB International                   | TY7894YE          | 57990878    | individual-supporter    | payment          | ODITRAINING | 100%          | 90                 | -90      | 0                  | 0   | 0     |
      | 2015-09-25 12:07:40 | Khalied Al Barrak                   | HC6986JK          | 58033847    | individual-supporter    | payment          | ODITRAINING | 100%          | 90                 | -90      | 0                  | 0   | 0     |
      | 2015-09-25 15:37:31 | Lydia Pintscher                     | LY3441CL          | 58040223    | individual-supporter    | payment          | MENTOR      | 100%          | 90                 | -90      | 0                  | 0   | 0     |
      | 2015-09-28 12:34:04 | Houses of Parliament                | TC9587KS          | 58172726    | individual-supporter    | payment          |             |               | 90                 | 0        | 90                 | 18  | 108   |
      | 2015-09-28 16:17:15 | Tobias Buerger                      | IG1866LU          | 58183744    | individual-supporter    | payment          | MENTOR      | 100%          | 90                 | -90      | 0                  | 0   | 0     |
      |                     |                                     |                   |             |                         |                  | totals      |               | 12250              | -5980    |                    | 390 | 6660  |

  Scenario: the booking value report contains the correct data
    Given I want to run the report for 2015-10-01 to 2015-10-31
    Then data for the booking value report should match:

      | product name                           | booking value | signup count | net    | tax    | total  |
      | individual-supporter NO COUPON         | 90.00         | 3            | 270.00 | 18.00  | 288.00 |
      | supporter_monthly ODISTARTUP           | 0.00          | 1            | 0.00   | 0.00   | 0.00   |
      | supporter_annual SUMMIT2015            | 604.80        | 1            | 604.80 | 120.96 | 725.76 |
      | holding-individual-supporter NO COUPON | 0.00          | 2            | 0.00   | 0.00   | 0.00   |
      | individual-supporter MENTOR            | 0.00          | 2            | 0.00   | 0.00   | 0.00   |

  Scenario: the cash report with coupon adjustments contains the correct data
    Given I want to run the report for 2015-02-20 to 2015-02-21
    Then data for the cash report should match:

      | date                | company                   | membership number | statement id | membership type            | transaction type | coupon    | coupon amount | original net price | discount | net after discount | tax | total |
      | 2015-02-20 11:48:49 | A J                       | HC2362FT          | 47125224     | individual-supporter       | payment          |           |               | 90                 | 0        | 90                 | 0   | 90    |
      | 2015-02-20 11:58:58 | A J                       | II3980RK          | 47125255     | individual-supporter       | payment          | SUPERFREE | 100%          | 90                 | -90      | 0                  | 0   | 0     |
      | 2015-02-20 12:07:19 | Company Name              | NK2275JC          | 47125709     | supporter_annual           | payment          |           |               | 720                | 0        | 720                | 0   | 720   |
      | 2015-02-20 12:18:40 | Company With Another Name | AD0597TT          | 47125774     | corporate-supporter_annual | payment          |           |               | 2200               | 0        | 2200               | 440 | 2640  |
      | 2015-02-20 14:15:48 | Credit Org                | ZT1079FY          | 47128978     | corporate-supporter_annual | payment          |           |               | 2200               | 0        | 2200               | 440 | 2640  |
      | 2015-02-20 17:06:16 | A J                       |                   | 47136873     | individual-supporter       | payment          |           |               | 90                 | 0        | 90                 | 18  | 108   |
      |                     |                           |                   |              |                            |                  | totals    |               | 5390               | -90      |                    | 898 | 6198  |

