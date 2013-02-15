@vcr
Feature: Monitoring eventbrite events

  In order to keep ODI event data up to date
  As an ODI training manager
  I want something to monitor all events on eventbrite on a regular basis

	# In many of these scenarios, we are using the order Given/Then/When, rather than
	# Given/When/Then. This is intentional, and lets us set up Resque expectations in
	# a better way in the steps.
  
	Scenario: Live events should be queued for checking
    Given an event in Eventbrite called "[Test Event 00] Drupal: Down the Rabbit Hole" with id 5441375300
    And that event has a url 'http://www.eventbrite.com/event/5441375300'
    And that event starts at 2013-03-17 19:00
    And that event ends at 2013-03-17 22:00
    And that event is being held at 'The office'
    And that event has 100 tickets called "Free Ticket" which cost GBP 0.00
    And that ticket type is on sale from 2013-02-11 09:00
    And that ticket type is on sale until 2013-03-17 18:00
    And that event has 100 tickets called "Cheap Ticket" which cost GBP 1.00
    And that ticket type is on sale until 2013-03-17 18:00
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
    When the attendee lister runs
    Then no errors should be raised
