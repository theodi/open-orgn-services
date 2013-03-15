@vcr @capsulecrm @wip
Feature: Synchronize data update in CapsuleCRM
  In order to keep the member directory up to date
  As a commercial team member
  I want my changes in CapsuleCRM to be reflected in the members directory
  
  Background:
    Given there is an existing organisation in CapsuleCRM called "Omni Consumer Products"
    And that organisation has a data tag called "Membership"
    And that organisation has a data tag called "DirectoryEntry"
  
  Scenario: Queue updated CapsuleCRM contacts for directory sync
    Then that organisation should be queued for sync
    When the capsule monitor runs
  
  @timecop
  Scenario: Don't queue non-updated CapsuleCRM contacts for directory sync
    Given that it's 3 hours into the future
    Then that organisation should not be queued for sync
    When the capsule monitor runs

  # Scenario: Create a new member in the directory
  #   Given context
  #   When event
  #   Then outcome
  # 
  # Scenario: Update existing members with changed data
  #   Given context
  #   When event
  #   Then outcome
  #   
  # Scenario: Activate existing members when flag is set in CapsuleCRM
  #   Given context
  #   When event
  #   Then outcome
  # 
  # Scenario: Deactivate existing members when flag is unset in CapsuleCRM
  #   Given context
  #   When event
  #   Then outcome