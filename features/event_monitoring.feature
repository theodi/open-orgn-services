@vcr @timecop
Feature: Monitoring eventbrite events

  In order to keep ODI event data up to date
  As an ODI training manager
  I want something to monitor all events on eventbrite on a regular basis

	# In many of these scenarios, we are using the order Given/Then/When, rather than
	# Given/When/Then. This is intentional, and lets us set up Resque expectations in
	# a better way in the steps.

	Scenario: Live events should be queued for checking
    Given that it's 2013-02-01 19:00
    Given an event in Eventbrite called "[Test Event 00] Drupal: Down the Rabbit Hole" with id 5441375300
    And that event has a url 'https://www.eventbrite.co.uk/e/test-event-00-drupal-down-the-rabbit-hole-tickets-5441375300?ref=ebapi'
    And that event has a capacity of 600
    And that event starts at 2020-06-17 19:00
    And that event ends at 2020-06-17 22:00
    And that event is being held at 'The office'
    And that event has 99 tickets called "Free Ticket" which cost GBP 0.00
    And that ticket type is on sale from 2013-02-11 09:00
    And that ticket type is on sale until 2013-06-17 18:00
    And that event has 93 tickets called "Cheap Ticket" which cost GBP 1.00
    And that ticket type is on sale from 2013-06-13 18:00
    And that ticket type is on sale until 2013-06-17 18:00
    And that event has 99 tickets called "Individual supporter package" which cost GBP 100.0
    And that ticket type is on sale from 2015-06-30 01:25
    And that ticket type is on sale until 2015-07-31 18:00
    And that event has 199 tickets called "Summit SME package" which cost GBP 205.65
    And that ticket type is on sale from 2015-07-01 04:30
    And that ticket type is on sale until 2020-06-17 18:00
    And that event has 99 tickets called "Summit platinum corporate package" which cost GBP 306.5
    And that ticket type is on sale from 2015-07-01 04:30
    And that ticket type is on sale until 2020-06-17 18:00
		Then that event should be queued for attendee checking
		When we poll eventbrite for all events

	Scenario: Draft events should not be queued for checking
    Given an event in Eventbrite called "Draft Event" with id 5530178914
    And that event is not live
		Then that event should not be queued for attendee checking
		When we poll eventbrite for all events

	Scenario: Historical events should not be queued for checking
    Given an event in Eventbrite called "Past Event" with id 5530182926
    And the event is happening in the past
		Then that event should not be queued for attendee checking
		When we poll eventbrite for all events

  # Check failures in eventbrite
  Scenario: Get empty list of attendees
    Given an event in Eventbrite called "Open Data, Law and Licensing" with id 5519765768
    And that event has not sold any tickets
    When the attendee monitor runs
    Then no errors should be raised
