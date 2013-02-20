@vcr
Feature: Add new signups to queue

  As a potential member, when I fill in my details, I want my details to be queued for further processing
  
  Scenario: Supporter signup
  
    Given that I want to sign up as a supporter
    When I visit the signup page
    And I enter my details
    Then my details should be queued for further processing
    When I click sign up
    
  Scenario: Member signup
  
    Given that I want to sign up as a member
    When I visit the signup page
    And I enter my details
    Then my details should be queued for further processing
    When I click sign up
    
  Scenario: Don't choose level
  
    Given that I want to sign up
    When I visit the signup page
    And I enter my details
    But I haven't chosen a membership level
    Then my details should not be queued
    When I click sign up
    And I should see an error

  Scenario: Don't enter name
  
    Given that I want to sign up
    When I visit the signup page
    And I enter my details
    But I don't enter my name
    Then my details should not be queued
    When I click sign up
    And I should see an error

  Scenario: Don't enter email
  
    Given that I want to sign up
    When I visit the signup page
    And I enter my details
    But I don't enter my email
    Then my details should not be queued
    When I click sign up
    And I should see an error
    
  Scenario: Don't enter Address Line 1
  
    Given that I want to sign up
    When I visit the signup page
    And I enter my details
    But I don't enter Address Line 1
    Then my details should not be queued
    When I click sign up
    And I should see an error
    
  Scenario: Don't enter City
  
    Given that I want to sign up
    When I visit the signup page
    And I enter my details
    But I don't enter my city
    Then my details should not be queued
    When I click sign up
    And I should see an error
    
  Scenario: Don't enter Country
  
    Given that I want to sign up
    When I visit the signup page
    And I enter my details
    But I don't enter my country
    Then my details should not be queued
    When I click sign up
    And I should see an error
    
  Scenario: Don't agree to terms and conditions

    Given that I want to sign up
    When I visit the signup page
    And I enter my details
    But I don't agree to the terms and conditions
    Then my details should not be queued
    When I click sign up
    And I should see an error