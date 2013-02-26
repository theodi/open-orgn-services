# Open Organisation Services

[![Build Status](http://jenkins.theodi.org/job/open-orgn-services-build-master/badge/icon)](http://jenkins.theodi.org/job/open-orgn-services-build-master/)
[![Dependency Status](https://gemnasium.com/theodi/open-orgn-services.png)](https://gemnasium.com/theodi/open-orgn-services)
[![Code Climate](https://codeclimate.com/github/theodi/open-orgn-services.png)](https://codeclimate.com/github/theodi/open-orgn-services)

This repository is for code for services that support the ODI's operation as an open organisation. Our aim is to publish open data as a mechanism to help us function more effectively, and to act as a demonstrator of both the technical and policy challenges.

[Feature documentation](https://relishapp.com/theodi/open-orgn-services/docs) can be found on Relish.

Setup
-----

Add to gemfile:

    gem 'open-orgn-services', :git => 'https://github.com/theodi/open-orgn-services.git'

And require if necessary:

    require 'open-orgn-services'

Configuration is loaded from environment variables. See the environment section below for the list of which variables must be set. The main one to make sure you add is `RESQUE_REDIS_SERVER`, which should be the hostname and port of the redis server where jobs should be queued.

License
-------

This code is open source under the MIT license. See the LICENSE.md file for 
full details.

Architecture
------------

This repository consists of a whole bunch of glue scripts which connect various other systems. They should all have the following features:

* Implemented as [resque jobs](https://github.com/defunkt/resque#section_Jobs).
* Minimal; each job should be as small as possible, spawing other jobs rather than executing big bits of code.
* Idempotent; they should be able to run many times with the same arguments and not cause problems.
* Testable; minimal jobs are very easy to test. This is generally done with cucumber features.

We use [VCR](https://github.com/vcr/vcr) to mock away any HTTP requests during tests.

Environment
-----------

The following environment variables should be set in order to use this gem.

    RESQUE_REDIS_SERVER
    
    EVENTBRITE_API_KEY
    EVENTBRITE_USER_KEY
    EVENTBRITE_ORGANIZER_ID
    
    XERO_CONSUMER_KEY
    XERO_CONSUMER_SECRET
    XERO_PRIVATE_KEY_PATH
    
    COURSES_RSYNC_PATH
    COURSES_TARGET_URL
    
    TRELLO_DEV_KEY
    TRELLO_DEV_SECRET
    TRELLO_MEMBER_KEY
    TRELLO_CLEANUP_BOARD
    
    GITHUB_LOGIN
    GITHUB_PASSWORD
    GITHUB_ORGANISATION
    
    LEFTRONIC_API_KEY
    LEFTRONIC_GITHUB_REPOS
    LEFTRONIC_GITHUB_FORKS
    LEFTRONIC_GITHUB_ISSUES
    LEFTRONIC_GITHUB_OPENPRS
    LEFTRONIC_GITHUB_PULLS
    LEFTRONIC_GITHUB_OUTGOING_PRS
    LEFTRONIC_GITHUB_WATCHERS
    LEFTRONIC_TRELLO_COUNT
    LEFTRONIC_TRELLO_LINE
    LEFTRONIC_JENKINS_HTML
    LEFTRONIC_JENKINS_TIME
    LEFTRONIC_IRC_COUNT
    
    HUBOT_USER_LIST
    
    JENKINS_URL