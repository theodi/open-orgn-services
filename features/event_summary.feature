@vcr @wip
Feature: Create a JSON description of all upcoming events

  In order to display upcoming events on the main website
  As a developer
  I want to be able to access a JSON file including the details from some client-side Javascript
  
  Scenario: Queue event summary generator
    Given an event in Eventbrite called "[Test Event 00] Drupal: Down the Rabbit Hole" with id 5441375300
    And another event in Eventbrite called "How to Find an Eventbrite Event ID" with id 5449726278
    And another event in Eventbrite called "Open Data, Law and Licensing" with id 5519765768
    Then the event summary generator should be queued
		When we poll eventbrite for all events
    
  Scenario: Generate JSON
    Given an event in Eventbrite called "[Test Event 00] Drupal: Down the Rabbit Hole" with id 5441375300
    And another event in Eventbrite called "How to Find an Eventbrite Event ID" with id 5449726278
    And another event in Eventbrite called "Open Data, Law and Licensing" with id 5519765768
    Then the summary uploader should be queued with the following JSON:
    """
    {
      "http://eventbrite.co.uk/...": {
        "@type": "http://schema.org/Event",
        "startDate": "2013-04-29T09:00:00",
        "endDate": "2013-05-01T17:00:00",
        "location": {
          "@type": "http://schema.org/Place",
          "name": "Covent Garden, London",
          "address": {
            "@type": "http://schema.org/PostalAddress",
            "name": "Wallspace Covent Garden",
            "streetAddress": "2 Dryden Street",
            "addressLocality": "Covent Garden",
            "postalCode": "WC2E 9NA",
            "addressCountry": "UK"
          },
          "geo": {
            "latitude": 51.514495,
            "longitude": -0.123028
          }
        },
        "offers": [
          {
            "@type": "http://schema.org/Offer",
            "name": "Standard Registration",
            "price": 1395.0,
            "priceCurrency": "GBP",
            "validFrom": "2013-03-29",
            "inventoryLevel": 13
          },
          {
            "@type": "http://schema.org/Offer",
            "name": "Early-Bird Registration",
            "price": 1255.0,
            "priceCurrency": "GBP",
            "validThrough": "2013-03-29",
            "inventoryLevel": 13
          }
        ]
      },
      "http://eventbrite.com/...": {
        "@type": "http://schema.org/Event"
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