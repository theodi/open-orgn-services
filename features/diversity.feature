@vcr
Feature: Send diversity sheet data to metrics API

  In order to keep the ODI amazing
  As an ODI personnel person
  I want something to monitor our diversity stats and store them over time

  Scenario: Diversity data should be stored in metrics API
    Then the following data should be stored in the "diversity-gender" metric
    """
    {
      "total": {
        "male"  : 15,
        "female": 22
      },
      "teams": {
        "board": {
          "male"  : 1,
          "female": 0
        },
        "smt": {
          "male"  : 2,
          "female": 1
        },
        "commercial": {
          "male"  : 3,
          "female": 6
        },
        "international": {
          "male"  : 1,
          "female": 4
        },
        "operations": {
          "male"  : 1,
          "female": 7
        },
        "technical": {
          "male"  : 7,
          "female": 4
        }
      }
    }
    """    
    When the diversity job runs