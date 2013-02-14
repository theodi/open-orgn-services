@vcr
Feature: Monitoring attendee signups

  In order to make sure that all event attendees are managed propery in ODI systems
  As a training manager
  I want something to monitor all attendee signups

	# In many of these scenarios, we are using the order Given/Then/When, rather than
	# Given/When/Then. This is intentional, and lets us set up Resque expectations in
	# a better way in the steps.
  
  Scenario: add users to invoicing queue if they ask for an invoice
    Given an event in Eventbrite called "[Test Event 00] Drupal: Down the Rabbit Hole" with id 5441375300
    And the net price of the event is 1.00
    And my email address is "bob.fish@example.com"
    Then I should be added to the invoicing queue
    When I sign up to that event and ask to be invoiced
    
  Scenario: don't add users to invoicing queue if get a free ticket
    Given an event in Eventbrite called "[Test Event 00] Drupal: Down the Rabbit Hole" with id 5441375300
    And my email address is "brian.fish@example.com"
    Then I should not be added to the invoicing queue
    When I sign up to that event and get a free ticket
  
  # VAT
  
  Scenario: invoices are raised net of VAT
    Given an event in Eventbrite called "[Test Event 00] Drupal: Down the Rabbit Hole" with id 5441375300
    And the gross price of the event in Eventbrite is 1.20
    And the net price of the event is 1.00
    And my email address is "bob.fish@example.com"
    Then I should be added to the invoicing queue
    When I sign up to that event and ask to be invoiced
