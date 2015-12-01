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
    Given I want to run the report for 2015-10-01 to 2015-10-31
    Then data for the cash report should match:

      | date                | company                             | membership number | statement id | membership type              | transaction type | coupon     | coupon amount | original net price | discount | net after discount | tax    | total  |
      | 2015-10-11 16:21:32 | iGeolise                            | ED3719XS          | 58807982     | supporter_monthly            | payment          |            |               | 60.00              | 0.00     | 60.00              | 12.00  | 72.00  |
      | 2015-10-13 23:01:56 | Ontotext                            | LO4564ZG          | 58908100     | supporter_legacy_annual      | payment          |            |               | 540.00             | 0.00     | 540.00             | 0.00   | 540.00 |
      | 2015-10-21 18:42:40 | Ordnance Survey                     | YF4159PF          | 59010822     | supporter_annual             | payment          |            |               | 720.00             | 0.00     | 720.00             | 0.00   | 720.00 |
      | 2015-10-23 23:02:00 | Market Research Society             | VG8264SU          | 59361793     | supporter_annual             | payment          |            |               | 720.00             | 0.00     | 720.00             | 144.00 | 864.00 |
      | 2015-10-22 09:21:14 | Big Data Partnership                | RE2054JO          | 59284291     | supporter_monthly            | payment          |            |               | 60.00              | 0.00     | 60.00              | 12.00  | 72.00  |
      | 2015-10-01 13:02:08 | Deliver Change Ltd                  | BG2374IK          | 58336601     | supporter_monthly            | payment          |            |               | 60.00              | 0.00     | 60.00              | 12.00  | 72.00  |
      | 2015-10-15 12:02:23 | IMIN LTD                            | UJ3966SJ          | 58979784     | supporter_monthly            | payment          |            |               | 60.00              | 0.00     | 60.00              | 12.00  | 72.00  |
      | 2015-10-22 16:02:17 | Signal Noise                        | GH9206SP          | 59295819     | supporter_monthly            | payment          |            |               | 60.00              | 0.00     | 60.00              | 12.00  | 72.00  |
      | 2015-10-07 20:41:25 | Singular Intelligence Limited       | NL4014DC          | 58646392     | supporter_monthly            | payment          |            | 360%          | 60.00              | -216.00  | -156.00            | 12.00  | -144.00 |
      | 2015-10-28 16:20:52 | Emu Analytics Limited               | TZ3130DN          | 59569837     | supporter_monthly            | payment          |            |               | 60.00              | 0.00     | 60.00              | 12.00  | 72.00  |
      | 2015-10-05 15:08:17 | GeoWise Limited                     | PZ0603JE          | 58534691     | supporter_monthly            | payment          |            |               | 60.00              | 0.00     | 60.00              | 12.00  | 72.00  |
      | 2015-10-14 10:21:07 | ESI Limited                         | ZU1679SB          | 58925166     | supporter_monthly            | payment          |            |               | 60.00              | 0.00     | 60.00              | 12.00  | 72.00  |
      | 2015-10-01 12:20:49 | Design For Social Change Ltd (D4SC) | AF2083GK          | 58334935     | supporter_monthly            | payment          |            |               | 60.00              | 0.00     | 60.00              | 12.00  | 72.00  |
      | 2015-10-02 07:42:30 | PwC                                 | SK4173EF          | 58394869     | individual-supporter         | payment          | MENTOR     | 100%          | 90.00              | -90.00   | 0.00               | 0.00   | 0.00   |
      | 2015-10-04 13:08:30 | Phil Allen                          | PB7953RJ          | 58489318     | individual-supporter         | payment          |            |               | 90.00              | 0.00     | 90.00              | 18.00  | 108.00 |
      | 2015-10-07 10:42:54 | Coleman & Pearse                    | TF0731HG          | 58624496     | individual-supporter         | payment          | MENTOR     | 100%          | 90.00              | -90.00   | 0.00               | 0.00   | 0.00   |
      | 2015-10-13 09:26:51 | John Kellas                         |                   | 58881052     | holding-individual-supporter | payment          |            |               | 0.00               | 0.00     | 0.00               | 0.00   | 0.00   |
      | 2015-10-13 09:30:05 | Gerald Milward-Oliver               |                   | 58881096     | holding-individual-supporter | payment          |            |               | 0.00               | 0.00     | 0.00               | 0.00   | 0.00   |
      | 2015-10-22 13:53:07 | ITO World Ltd                       | EX8473WQ          | 59291184     | supporter_annual             | payment          | SUMMIT2015 | 16%           | 720.00             | -115.20  | 604.80             | 120.96 | 725.76 |
      | 2015-10-23 20:38:20 | Hend Saud Alhazzani                 | UK1920ZW          | 59356044     | individual-supporter         | payment          |            |               | 90.00              | 0.00     | 90.00              | 0.00   | 90.00  |
      | 2015-10-26 11:45:05 | Resurgence                          | DM2894ZW          | 59453839     | supporter_monthly            | payment          | ODISTARTUP | 100%          | 60.00              | -60.00   | 0.00               | 0.00   | 0.00   |
      | 2015-10-26 15:02:15 | Seunghun Jang                       | NK9481CJ          | 59459652     | individual-supporter         | payment          |            |               | 90.00              | 0.00     | 90.00              | 0.00   | 90.00  |
      |                     |                                     |                   |              |                              |                  | totals     |               | 3810               | -572     |                    | 402    | 3641    |

  Scenario: the cash report contains the correct data
    Given I want to run the report for 2015-09-01 to 2015-09-30
    Then data for the cash report should match:

      | date                | company                             | membership number | statement id| membership type         | transaction type | coupon      | coupon amount | original net price | discount | net after discount | tax    | total   |
      | 2015-09-11 16:21:21 | iGeolise                            | ED3719XS          | 57413813    | supporter_monthly       | payment          |             |               | 60.00              | 0.00     | 60.00              | 12.00  | 72.00   |
      | 2015-09-02 15:33:08 | Images&Co Ltd                       | VM9556SP          | 56968155    | supporter_legacy_annual | payment          |             |               | 540.00             | 0.00     | 540.00             | 0.00   | 540.00  |
      | 2015-09-07 23:01:56 | Oasis Loss Modelling Framework      | DH9645KA          | 57240140    | supporter_legacy_annual | payment          |             |               | 540.00             | 0.00     | 540.00             | 108.00 | 648.00  |
      | 2015-09-22 09:21:00 | Big Data Partnership                | RE2054JO          | 57887343    | supporter_monthly       | payment          |             |               | 60.00              | 0.00     | 60.00              | 12.00  | 72.00   |
      | 2015-09-01 13:01:39 | Deliver Change Ltd                  | BG2374IK          | 56931908    | supporter_monthly       | payment          |             |               | 60.00              | 0.00     | 60.00              | 12.00  | 72.00   |
      | 2015-09-15 12:01:54 | IMIN LTD                            | UJ3966SJ          | 57581240    | supporter_monthly       | payment          |             |               | 60.00              | 0.00     | 60.00              | 12.00  | 72.00   |
      | 2015-09-22 16:01:59 | Signal Noise                        | GH9206SP          | 57899184    | supporter_monthly       | payment          |             |               | 60.00              | 0.00     | 60.00              | 12.00  | 72.00   |
      | 2015-09-07 20:40:55 | Singular Intelligence Limited       | NL4014DC          | 57234271    | supporter_monthly       | payment          |             |               | 60.00              | 0.00     | 60.00              | 12.00  | 72.00   |
      | 2015-09-28 16:20:44 | Emu Analytics Limited               | TZ3130DN          | 58183839    | supporter_monthly       | payment          |             |               | 60.00              | 0.00     | 60.00              | 12.00  | 72.00   |
      | 2015-09-05 15:01:30 | GeoWise Limited                     | PZ0603JE          | 57137691    | supporter_monthly       | payment          |             |               | 60.00              | 0.00     | 60.00              | 12.00  | 72.00   |
      | 2015-09-14 10:21:04 | ESI Limited                         | ZU1679SB          | 57531564    | supporter_monthly       | payment          |             |               | 60.00              | 0.00     | 60.00              | 12.00  | 72.00   |
      | 2015-09-15 12:32:51 | Christiana Dankwa                   | WT8786FG          | 57582066    | individual-supporter    | refund           |             |               | -90.00             | 0.00     |                    | -18.00 | -108.00 |
      | 2015-09-01 12:01:52 | Design For Social Change Ltd (D4SC) | AF2083GK          | 56929639    | supporter_monthly       | payment          |             |               | 60.00              | 0.00     | 60.00              | 12.00  | 72.00   |
      | 2015-09-04 09:56:48 | Clanmil Housing Association         | AQ0201OD          | 57085528    | individual-supporter    | payment          | ODITRAINING | 100%          | 90.00              | -90.00   | 0.00               | 0.00   | 0.00    |
      | 2015-09-14 07:35:49 | Institute for Applied Informatics   | WG0685GG          | 57527632    | individual-supporter    | payment          | MENTOR      | 100%          | 90.00              | -90.00   | 0.00               | 0.00   | 0.00    |
      | 2015-09-14 07:40:02 | Wolters Kluwer Deutschland GmbH     | YN4078UF          | 57527655    | individual-supporter    | payment          | MENTOR      | 100%          | 90.00              | -90.00   | 0.00               | 0.00   | 0.00    |
      | 2015-09-14 08:25:04 | Lieven Janssen                      | BO7112XU          | 57528673    | individual-supporter    | payment          | MENTOR      | 100%          | 90.00              | -90.00   | 0.00               | 0.00   | 0.00    |
      | 2015-09-14 08:35:14 | 201010 Ltd                          | VZ6871CJ          | 57528785    | individual-supporter    | payment          | MENTOR      | 100%          | 90.00              | -90.00   | 0.00               | 0.00   | 0.00    |
      | 2015-09-14 09:20:27 | Christoph Pinkel                    | DD6238PE          | 57529892    | individual-supporter    | payment          | MENTOR      | 100%          | 90.00              | -90.00   | 0.00               | 0.00   | 0.00    |
      | 2015-09-14 09:48:37 | Interdependent Thoughts             | II8695SI          | 57530845    | individual-supporter    | payment          | MENTOR      | 100%          | 90.00              | -90.00   | 0.00               | 0.00   | 0.00    |
      | 2015-09-14 10:43:34 | Zach Beauvais                       | TR6735OJ          | 57532290    | individual-supporter    | payment          | MENTOR      | 100%          | 90.00              | -90.00   | 0.00               | 0.00   | 0.00    |
      | 2015-09-14 14:50:57 | Kate Northstone                     | UB4712EG          | 57539667    | individual-supporter    | payment          | ODITRAINING | 100%          | 90.00              | -90.00   | 0.00               | 0.00   | 0.00    |
      | 2015-09-15 20:06:31 | Niels Erik Kaaber Rasmussen         | HV7343ZD          | 57601748    | individual-supporter    | payment          | MENTOR      | 100%          | 90.00              | -90.00   | 0.00               | 0.00   | 0.00    |
      | 2015-09-16 15:24:39 | University of Milano Bicocca        | WP2222EE          | 57638251    | individual-supporter    | payment          | MENTOR      | 100%          | 90.00              | -90.00   | 0.00               | 0.00   | 0.00    |
      | 2015-09-16 15:45:35 | emapsite                            | DW1850JL          | 57638980    | individual-supporter    | payment          | ODITRAINING | 100%          | 90.00              | -90.00   | 0.00               | 0.00   | 0.00    |
      | 2015-09-18 07:46:18 | Daniel Rudmark                      | EX3510UH          | 57717841    | individual-supporter    | payment          | MENTOR      | 100%          | 90.00              | -90.00   | 0.00               | 0.00   | 0.00    |
      | 2015-09-18 13:38:24 | Carl Rodrigues                      | TP5921MO          | 57725195    | individual-supporter    | payment          | MENTOR      | 100%          | 90.00              | -90.00   | 0.00               | 0.00   | 0.00    |
      | 2015-09-19 19:04:21 | Empolis                             | AH3305JS          | 57777465    | individual-supporter    | payment          | MENTOR      | 100%          | 90.00              | -90.00   | 0.00               | 0.00   | 0.00    |
      | 2015-09-21 06:11:07 | British Telecom                     | KJ7341EC          | 57838985    | individual-supporter    | payment          | MENTOR      | 100%          | 90.00              | -90.00   | 0.00               | 0.00   | 0.00    |
      | 2015-09-24 13:18:45 | CABI                                | GG8714TK          | 57989237    | individual-supporter    | payment          | ODITRAINING | 100%          | 90.00              | -90.00   | 0.00               | 0.00   | 0.00    |
      | 2015-09-24 13:21:02 | CAB International                   | MK2889FR          | 57989343    | individual-supporter    | payment          | ODITRAINING | 100%          | 90.00              | -90.00   | 0.00               | 0.00   | 0.00    |
      | 2015-09-24 13:27:59 | CABI                                | IW1257LR          | 57989719    | individual-supporter    | payment          | ODITRAINING | 100%          | 90.00              | -90.00   | 0.00               | 0.00   | 0.00    |
      | 2015-09-24 14:04:16 | CAB International                   | TY7894YE          | 57990878    | individual-supporter    | payment          | ODITRAINING | 100%          | 90.00              | -90.00   | 0.00               | 0.00   | 0.00    |
      | 2015-09-25 12:07:40 | Khalied Al Barrak                   | HC6986JK          | 58033847    | individual-supporter    | payment          | ODITRAINING | 100%          | 90.00              | -90.00   | 0.00               | 0.00   | 0.00    |
      | 2015-09-25 15:37:31 | Lydia Pintscher                     | LY3441CL          | 58040223    | individual-supporter    | payment          | MENTOR      | 100%          | 90.00              | -90.00   | 0.00               | 0.00   | 0.00    |
      | 2015-09-28 12:34:04 | Houses of Parliament                | TC9587KS          | 58172726    | individual-supporter    | payment          |             |               | 90.00              | 0.00     | 90.00              | 18.00  | 108.00  |
      | 2015-09-28 16:17:15 | Tobias Buerger                      | IG1866LU          | 58183744    | individual-supporter    | payment          | MENTOR      | 100%          | 90.00              | -90.00   | 0.00               | 0.00   | 0.00    |
      |                     |                                     |                   |             |                         |                  | totals      |               | 3750            | -2070 |                    | 228 | 1908 |

  Scenario: the booking value report contains the correct data
    Given I want to run the report for 2015-10-01 to 2015-10-31
    Then data for the booking value report should match:

      | product name                           | booking value | signup count | net    | tax    | total  |
      | individual-supporter NO COUPON         | 90.00         | 3            | 270.00 | 18.00  | 288.00 |
      | supporter_monthly ODISTARTUP           | 0.00          | 1            | 0.00   | 0.00   | 0.00   |
      | supporter_annual SUMMIT2015            | 604.80        | 1            | 604.80 | 120.96 | 725.76 |
      | holding-individual-supporter NO COUPON | 0.00          | 2            | 0.00   | 0.00   | 0.00   |
      | individual-supporter MENTOR            | 0.00          | 2            | 0.00   | 0.00   | 0.00   |

