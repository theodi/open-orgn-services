@vcr
Feature: Create a JSON description of all upcoming events

  In order to display upcoming events on the main website
  As a developer
  I want to be able to access a JSON file including the details from some client-side Javascript
  
  Background:
    Given that it's 2013-02-01 19:00
    And the following events exist:
    
      | title                                        | id         | url                                        | starts_at        | ends_at          | capacity | location            |
      | [Test Event 00] Drupal: Down the Rabbit Hole | 5441375300 | http://www.eventbrite.com/event/5441375300 | 2013-03-17 19:00 | 2013-03-17 22:00 | 100      | The office          |
      | How to Find an Eventbrite Event ID           | 5449726278 | http://foobarrubbishevent.eventbrite.com   | 2013-03-24 19:00 | 2013-03-24 22:00 | 10       |                     | 
      | Open Data, Law and Licensing                 | 5519765768 | http://www.eventbrite.com/event/5519765768 | 2013-04-16 09:30 | 2013-04-16 12:30 | 120      | Open Data Institute |
      
    And the events have the following ticket types:
    
      | event_id    | name                                  | price   | currency | starts_at        | ends_at          | tickets   |
      | 5441375300  | Free Ticket                           | 0.00    | GBP      | 2013-02-11 09:00 | 2013-03-17 18:00 | 99        |
      | 5441375300  | Cheap Ticket                          | 1.00    | GBP      |                  | 2013-03-17 18:00 | 94        |
      | 5449726278  | Free                                  | 0.00    | GBP      |                  | 2013-03-24 18:00 | 9         |
      | 5519765768  | Full Registration                     | 1231.50 | GBP      |                  | 2013-04-16 08:30 | 100       |
      | 5519765768  | Early Bird                            | 195.40  | GBP      |                  | 2013-04-16 08:30 | 100       |
      | 5519765768  | Members, Civil Servants and Charities | 185.15  | GBP      |                  | 2013-04-16 08:30 | 100       |
  
  Scenario: Queue event summary generator
    Then the event summary generator should be queued
		When we poll eventbrite for all events
    
  Scenario: Generate JSON
    Then the summary uploader should be queued with the following JSON:
    """
    {
      "http://www.eventbrite.com/event/5441375300": {
        "name": "[Test Event 00] Drupal: Down the Rabbit Hole",
        "@type": "http://schema.org/Event",
        "startDate": "2013-03-17T19:00:00+00:00",
        "endDate": "2013-03-17T22:00:00+00:00",
        "capacity": 100,
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
            "validThrough": "2013-03-17T18:00:00+00:00",
            "inventoryLevel": 99,
            "validFrom": "2013-02-11T09:00:00+00:00"
          },
          {
            "@type": "http://schema.org/Offer",
            "name": "Cheap Ticket",
            "price": 1.0,
            "priceCurrency": "GBP",
            "validThrough": "2013-03-17T18:00:00+00:00",
            "inventoryLevel": 94
          }
        ]
      },
      "http://foobarrubbishevent.eventbrite.com": {
        "name": "How to Find an Eventbrite Event ID",
        "@type": "http://schema.org/Event",
        "startDate": "2013-03-24T19:00:00+00:00",
        "endDate": "2013-03-24T22:00:00+00:00",
        "capacity": 10,
        "offers": [
          {
            "@type": "http://schema.org/Offer",
            "name": "Free",
            "price": 0.0,
            "priceCurrency": "GBP",
            "validThrough": "2013-03-24T18:00:00+00:00",
            "inventoryLevel": 9
          }
        ]
      },
      "http://www.eventbrite.com/event/5519765768": {
        "name": "Open Data, Law and Licensing",
        "@type": "http://schema.org/Event",
        "startDate": "2013-04-16T09:30:00+00:00",
        "endDate": "2013-04-16T12:30:00+00:00",
        "capacity": 120,
        "location": {
          "@type": "http://schema.org/Place",
          "name": "Open Data Institute"
        },
        "offers": [
          {
            "@type": "http://schema.org/Offer",
            "name": "Full Registration",
            "price": 1231.5,
            "priceCurrency": "GBP",
            "validThrough": "2013-04-16T08:30:00+00:00",
            "inventoryLevel": 100
          },
          {
            "@type": "http://schema.org/Offer",
            "name": "Early Bird",
            "price": 195.4,
            "priceCurrency": "GBP",
            "validThrough": "2013-04-16T08:30:00+00:00",
            "inventoryLevel": 100
          },
          {
            "@type": "http://schema.org/Offer",
            "name": "Members, Civil Servants and Charities",
            "price": 185.15,
            "priceCurrency": "GBP",
            "validThrough": "2013-04-16T08:30:00+00:00",
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
    Then the json should be written to a temporary file
    And the temporary file should be rsync'd to the web server
    When the summary uploader runs
    Then the JSON document should be available at the target URL