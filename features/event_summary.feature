@vcr @timecop
Feature: Create a JSON description of all upcoming events

  In order to display upcoming events on the main website
  As a developer
  I want to be able to access a JSON file including the details from some client-side Javascript

  Background:
    Given that it's 2013-04-22 19:00
    And the following events exist:

      | title                                                | id         | url                                                                                                            | starts_at        | ends_at          | capacity | location            |
      | Past Event                                           | 5530182926 | https://www.eventbrite.co.uk/e/past-event-tickets-5530182926?ref=ebapi                                         | 2013-02-14 07:00 | 2013-02-14 08:00 | 100      |                     |
      | Big Event (2013-02-14)                               | 5531683414 | https://www.eventbrite.co.uk/e/big-event-2013-02-14-tickets-5531683414?ref=ebapi                               | 2013-02-14 19:00 | 2013-02-14 22:00 | 10       | The ODI             |
      | Friday lunchtime lectures: Something something data  | 6339143549 | https://www.eventbrite.co.uk/e/friday-lunchtime-lectures-something-something-data-tickets-6339143549?ref=ebapi | 2013-05-31 13:00 | 2013-05-31 13:45 | 100      | The ODI             |
      | Friday lunchtime lectures: We heard you like data... | 6339320077 | https://www.eventbrite.co.uk/e/friday-lunchtime-lectures-we-heard-you-like-data-tickets-6339320077?ref=ebapi   | 2013-06-07 13:00 | 2013-06-07 13:45 | 100      | The ODI             |
      | Open Data, Law and Licensing                         | 5519765768 | https://www.eventbrite.co.uk/e/open-data-law-and-licensing-tickets-5519765768?ref=ebapi                        | 2013-06-16 09:30 | 2013-06-16 12:30 | 100      | Open Data Institute |
      | How to Find an Eventbrite Event ID                   | 5449726278 | https://www.eventbrite.co.uk/e/how-to-find-an-eventbrite-event-id-tickets-5449726278?ref=ebapi                 | 2013-06-24 19:00 | 2013-06-24 22:00 | 10       |                     |
      | [Test Event 00] Drupal: Down the Rabbit Hole         | 5441375300 | https://www.eventbrite.co.uk/e/test-event-00-drupal-down-the-rabbit-hole-tickets-5441375300?ref=ebapi          | 2020-06-17 19:00 | 2020-06-17 22:00 | 600      | The office          |

    And the events have the following ticket types:

      | event_id    | name                                  | price   | currency | starts_at        | ends_at          | tickets   |
      | 5531683414  | Cheap Seats                           | 1.0     | GBP      |                  | 2013-02-14 18:00 | 10        |
      | 5530182926  | Free but useless                      | 0.00    | GBP      |                  | 2013-02-14 06:00 | 100       |
      | 5441375300  | Free Ticket                           | 0.00    | GBP      | 2013-02-11 09:00 | 2013-06-17 18:00 | 99        |
      | 5441375300  | Cheap Ticket                          | 1.00    | GBP      | 2013-06-13 18:00 | 2013-06-17 18:00 | 93        |
      | 5449726278  | Free                                  | 0.00    | GBP      |                  | 2013-06-24 18:00 | 9         |
      | 5519765768  | Full Registration                     | 1234.95 | GBP      |                  | 2013-06-16 08:30 | 100       |
      | 5519765768  | Early Bird                            | 195.74  | GBP      |                  | 2013-06-16 08:30 | 100       |
      | 5519765768  | Members, Civil Servants and Charities | 185.49  | GBP      |                  | 2013-06-16 08:30 | 100       |
      | 6339143549  | Guest                                 | 0       | GBP      |                  | 2013-05-31 12:00 | 100       |
      | 6339320077  | Guest                                 | 0       | GBP      |                  | 2013-06-07 12:00 | 100       |
      | 5441375300  | Individual supporter package          | 100.0   | GBP      | 2015-06-30 01:25 | 2015-07-31 18:00 | 99        |
      | 5441375300  | Summit SME package                    | 205.65  | GBP      | 2015-07-01 04:30 | 2020-06-17 18:00 | 199       |
      | 5441375300  | Summit platinum corporate package     | 306.5   | GBP      | 2015-07-01 04:30 | 2020-06-17 18:00 | 99        |

  Scenario: Queue event summary generator
    Then the event summary generator should be queued
		When we poll eventbrite for all events

  Scenario: Generate JSON
    Then the courses summary uploader should be queued with the following JSON:
    """
    {
      "https://www.eventbrite.co.uk/e/test-event-00-drupal-down-the-rabbit-hole-tickets-5441375300?ref=ebapi": {
        "name": "[Test Event 00] Drupal: Down the Rabbit Hole",
        "@type": "http://schema.org/EducationEvent",
        "startDate": "2020-06-17T19:00:00+00:00",
        "endDate": "2020-06-17T22:00:00+00:00",
        "additionalType": "http://linkedscience.org/teach/ns/#Course",
        "status": "Live",
        "location": {
          "@type": "http://schema.org/Place",
          "name": "The office"
        },
        "offers": [
          {
            "@type": "http://schema.org/Offer",
            "name": "Free Ticket",
            "price": 0.0,
            "priceCurrency": "GBP",
            "validThrough": "2013-06-17T18:00:00+00:00",
            "inventoryLevel": 99,
            "validFrom": "2013-02-11T09:00:00+00:00"
          },
          {
            "@type": "http://schema.org/Offer",
            "name": "Cheap Ticket",
            "price": 1.0,
            "priceCurrency": "GBP",
            "validThrough": "2013-06-17T18:00:00+00:00",
            "inventoryLevel": 93,
            "validFrom": "2013-06-13T18:00:00+00:00"
          },
          {
            "@type": "http://schema.org/Offer",
            "name": "Individual supporter package",
            "price": 100.0,
            "priceCurrency": "GBP",
            "validThrough": "2015-07-31T18:00:00+00:00",
            "inventoryLevel": 99,
            "validFrom": "2015-06-30T01:25:00+00:00"
          },
          {
            "@type": "http://schema.org/Offer",
            "name": "Summit SME package",
            "price": 205.65,
            "priceCurrency": "GBP",
            "validThrough": "2020-06-17T18:00:00+00:00",
            "inventoryLevel": 199,
            "validFrom": "2015-07-01T04:30:00+00:00"
          },
          {
            "@type": "http://schema.org/Offer",
            "name": "Summit platinum corporate package",
            "price": 306.5,
            "priceCurrency": "GBP",
            "validThrough": "2020-06-17T18:00:00+00:00",
            "inventoryLevel": 99,
            "validFrom": "2015-07-01T04:30:00+00:00"
          }
        ]
      },
      "https://www.eventbrite.co.uk/e/how-to-find-an-eventbrite-event-id-tickets-5449726278?ref=ebapi": {
        "name": "How to Find an Eventbrite Event ID",
        "@type": "http://schema.org/EducationEvent",
        "startDate": "2013-06-24T19:00:00+00:00",
        "endDate": "2013-06-24T22:00:00+00:00",
        "additionalType": "http://linkedscience.org/teach/ns/#Course",
        "status": "Live",
        "offers": [
          {
            "@type": "http://schema.org/Offer",
            "name": "Free",
            "price": 0.0,
            "priceCurrency": "GBP",
            "validThrough": "2013-06-24T18:00:00+00:00",
            "inventoryLevel": 9
          }
        ]
      },
      "https://www.eventbrite.co.uk/e/open-data-law-and-licensing-tickets-5519765768?ref=ebapi": {
        "name": "Open Data, Law and Licensing",
        "@type": "http://schema.org/EducationEvent",
        "startDate": "2013-06-16T09:30:00+00:00",
        "endDate": "2013-06-16T12:30:00+00:00",
        "additionalType": "http://linkedscience.org/teach/ns/#Course",
        "status": "Live",
        "location": {
          "@type": "http://schema.org/Place",
          "name": "Open Data Institute"
        },
        "offers": [
          {
            "@type": "http://schema.org/Offer",
            "name": "Full Registration",
            "price": 1234.95,
            "priceCurrency": "GBP",
            "validThrough": "2013-06-16T08:30:00+00:00",
            "inventoryLevel": 100
          },
          {
            "@type": "http://schema.org/Offer",
            "name": "Early Bird",
            "price": 195.74,
            "priceCurrency": "GBP",
            "validThrough": "2013-06-16T08:30:00+00:00",
            "inventoryLevel": 100
          },
          {
            "@type": "http://schema.org/Offer",
            "name": "Members, Civil Servants and Charities",
            "price": 185.49,
            "priceCurrency": "GBP",
            "validThrough": "2013-06-16T08:30:00+00:00",
            "inventoryLevel": 100
          }
        ]
      },
      "https://www.eventbrite.co.uk/e/big-event-2013-02-14-tickets-5531683414?ref=ebapi": {
        "name": "Big Event (2013-02-14)",
        "@type": "http://schema.org/EducationEvent",
        "startDate": "2013-02-14T19:00:00+00:00",
        "endDate": "2013-02-14T22:00:00+00:00",
        "additionalType": "http://linkedscience.org/teach/ns/#Course",
        "status": "Completed",
        "location": {
          "@type": "http://schema.org/Place",
          "name": "The ODI"
        },
        "offers": [
          {
            "@type": "http://schema.org/Offer",
            "name": "Cheap Seats",
            "price": 1.0,
            "priceCurrency": "GBP",
            "validThrough": "2013-02-14T18:00:00+00:00",
            "inventoryLevel": 10
          }
        ]
      },
      "https://www.eventbrite.co.uk/e/past-event-tickets-5530182926?ref=ebapi": {
        "name": "Past Event",
        "@type": "http://schema.org/EducationEvent",
        "startDate": "2013-02-14T07:00:00+00:00",
        "endDate": "2013-02-14T08:00:00+00:00",
        "additionalType": "http://linkedscience.org/teach/ns/#Course",
        "status": "Completed",
        "offers": [
          {
            "@type": "http://schema.org/Offer",
            "name": "Free but useless",
            "price": 0.0,
            "priceCurrency": "GBP",
            "validThrough": "2013-02-14T06:00:00+00:00",
            "inventoryLevel": 100
          }
        ]
      }
    }
    """
    And the lectures summary uploader should be queued with the following JSON:
    """
    {
      "https://www.eventbrite.co.uk/e/friday-lunchtime-lectures-we-heard-you-like-data-tickets-6339320077?ref=ebapi": {
        "name": "Friday lunchtime lectures: We heard you like data...",
        "@type": "http://schema.org/EducationEvent",
        "startDate": "2013-06-07T13:00:00+00:00",
        "endDate": "2013-06-07T13:45:00+00:00",
        "capacity": 100,
        "additionalType": "http://linkedscience.org/teach/ns/#Lecture",
        "status": "Live",
        "location": {
          "@type": "http://schema.org/Place",
          "name": "The ODI"
        },
        "offers": [
          {
            "@type": "http://schema.org/Offer",
            "name": "Guest",
            "price": 0.0,
            "priceCurrency": "GBP",
            "validThrough": "2013-06-07T12:00:00+00:00",
            "inventoryLevel": 100
          }
        ]
      },
      "https://www.eventbrite.co.uk/e/friday-lunchtime-lectures-something-something-data-tickets-6339143549?ref=ebapi": {
        "name": "Friday lunchtime lectures: Something something data",
        "@type": "http://schema.org/EducationEvent",
        "startDate": "2013-05-31T13:00:00+00:00",
        "endDate": "2013-05-31T13:45:00+00:00",
        "capacity": 100,
        "additionalType": "http://linkedscience.org/teach/ns/#Lecture",
        "status": "Live",
        "location": {
          "@type": "http://schema.org/Place",
          "name": "The ODI"
        },
        "offers": [
          {
            "@type": "http://schema.org/Offer",
            "name": "Guest",
            "price": 0.0,
            "priceCurrency": "GBP",
            "validThrough": "2013-05-31T12:00:00+00:00",
            "inventoryLevel": 100
          }
        ]
      }
    }
    """
		When the event summary generator is run

  Scenario: Upload JSON to web server
    Given a JSON document like this:
    """
    {"foo":"bar"}
    """
    When the summary uploader runs
    Then the JSON document should be available at the target URL
