@vcr
Feature: Create a JSON description of all upcoming lunchtime lectures
  
  In order to display data about upcoming lunchtime lectures on the website
  As a developer
  I want to be able to take data from Eventbrite and represent it as a JSON file
  
  Background:
    
    Given that it's 2013-04-17 19:00
    And the following events exist:
    
      | title                                                | id         | url                                        | starts_at        | ends_at          | capacity | location |           
      | Friday lunchtime lectures: Something something data  | 6339143549 | http://www.eventbrite.com/event/6339143549 | 2013-05-31 13:00 | 2013-05-31 13:45 | 100      | The ODI  |
      | Friday lunchtime lectures: We heard you like data... | 6339320077 | http://www.eventbrite.com/event/6339320077 | 2013-06-07 13:00 | 2013-06-07 13:45 | 100      | The ODI  |
      
    And the events have the following ticket types:
    
      | event_id    | name  | price   | currency | starts_at | ends_at          | tickets   |
      | 6339143549  | Guest | 0       | GBP      |           | 2013-05-31 12:00 | 100       |
      | 6339320077  | Guest | 0       | GBP      |           | 2013-06-07 12:00 | 100       |

  Scenario: Queue event summary generator
    Then the event summary generator should be queued
		When we poll eventbrite for all events
  
  Scenario: Generate JSON
    Then the summary uploader should be queued with the following JSON:
    """
    {
      "http://www.eventbrite.com/event/6339143549": {
        "name": "Friday lunchtime lectures: Something something data",
        "@type": "http://schema.org/Event",
        "startDate": "2013-05-31T13:00:00+00:00",
        "endDate": "2013-05-31T13:45:00+00:00",
        "capacity": 100,
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
      },
      "http://www.eventbrite.com/event/6339320077": {
        "name": "Friday lunchtime lectures: We heard you like data...",
        "@type": "http://schema.org/Event",
        "startDate": "2013-06-07T13:00:00+00:00",
        "endDate": "2013-06-07T13:45:00+00:00",
        "capacity": 100,
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
      }
    }
    """
    When the event summary generator is run