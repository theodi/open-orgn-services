Feature: Invoicing for training events

  In order to make sure that all event attendees are managed propery in ODI systems
  As a training manager
  I want something to monitor all attendee signups

	# In many of these scenarios, we are using the order Given/Then/When, rather than
	# Given/When/Then. This is intentional, and lets us set up Resque expectations in
	# a better way in the steps.
  
  Scenario:
    Given there is an event in Eventbrite with id 5441375300 which costs 0.66 to attend
    And my email address is 'james.smith@theodi.org'
    Then I should be added to the invoicing queue
    When I sign up to that event and ask to be invoiced
    
  Scenario:
    Given there is an event in Eventbrite with id 5441375300
    And my email address is 'sam.pikesley@theodi.org'
    Then I should not be added to the invoicing queue
    When I sign up to that event and get a free ticket