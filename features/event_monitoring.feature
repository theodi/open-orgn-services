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
		Then that event should be queued for attendee checking
		When we poll eventbrite for all events
	
	Scenario: Draft events should not be queued for checking
    Given an event in Eventbrite called "[Test Event 00] Drupal: Down the Rabbit Hole" with id 5449726278 
    And that event is not live
		Then that event should not be queued for attendee checking
		When we poll eventbrite for all events