@vcr
Feature: Add new signups to queue

  As a potential member, when I fill in my details, I want my details to be queued for further processing
  
  Scenario: Supporter signup
  
    Given that I want to sign up as a supporter
    When I visit the signup page
    And I enter my details
    And I agree to the terms and conditions
    Then my details should be queued for further processing
    When I click sign up
    
  Scenario: Member signup
  
    Given that I want to sign up as a member
    When I visit the signup page
    And I enter my details
    And I agree to the terms and conditions
    Then my details should be queued for further processing
    When I click sign up