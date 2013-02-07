Feature: Invoicing for training events

  In order to be invoiced for the training so that my company or government department can pay for it
  As a prospective delegate
  I want to be sent an invoice when I sign up to attend an event

	# In many of these scenarios, we are using the order Given/Then/When, rather than
	# Given/When/Then. This is intentional, and lets us set up Resque expectations in
	# a better way in the steps.
  
	Scenario:
    Given there is an event in Eventbrite with id 5441375300
		Then that event should be queued for attendee checking
		When we poll eventbrite for all events
	
	Scenario:
    Given there is an event in Eventbrite with id 5449726278 which is not live
		Then that event should not be queued for attendee checking
		When we poll eventbrite for all events

  Scenario:
    Given there is an event in Eventbrite with id 5441375300 which costs 0.66 to attend
    And my email address is 'james.smith@theodi.org'
    Then I should be added to the invoicing queue
    When I sign up to that event and asks to be invoiced
    
  Scenario:
    Given there is an event in Eventbrite with id 5441375300
		And my email address is 'sam.pikesley@theodi.org'
    Then I should not be added to the invoicing queue
    When I sign up to that event and get a free ticket

  Scenario:
    Given 'james.smith@theodi.org' needs to be invoiced for 0.66
    Then an invoice should be raised in Xero