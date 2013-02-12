Feature: Invoicing for training events

  In order to make sure that all event attendees are managed propery in ODI systems
  As a training manager
  I want something to monitor all attendee signups

	# In many of these scenarios, we are using the order Given/Then/When, rather than
	# Given/When/Then. This is intentional, and lets us set up Resque expectations in
	# a better way in the steps.
  
  Scenario:
    Given an event in Eventbrite called "[Test Event 00] Drupal: Down the Rabbit Hole" with id 5441375300
    And my email address is "bob.fish@example.com"
    Then I should be added to the invoicing queue
    When I sign up to that event and ask to be invoiced
    
  Scenario:
    Given an event in Eventbrite called "[Test Event 00] Drupal: Down the Rabbit Hole" with id 5441375300
    And my email address is "bob.fish@example.com"
    Then I should be added to the invoicing queue
    When I sign up to that event and ask to be invoiced

  Scenario:
    Given an event in Eventbrite called "[Test Event 00] Drupal: Down the Rabbit Hole" with id 5441375300
    And my email address is "brian.fish@example.com"
    Then I should not be added to the invoicing queue
    When I sign up to that event and get a free ticket
  
  # VAT
  
  Scenario:
    Given an event in Eventbrite called "[Test Event 00] Drupal: Down the Rabbit Hole" with id 5441375300
    And the price of the event is 1.00
    And my email address is "bob.fish@example.com"
    # Eventbrite should be adding VAT on top
    Then the total cost to be invoiced should be 1.2
    # We send net cost into Xero
    And the net cost to be invoiced should be 1.00
    When I sign up to that event and ask to be invoiced
