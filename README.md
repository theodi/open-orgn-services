# Open Organisation Services

This repository is for code for services that support the ODI's operation as an open organisation. Our aim is to publish open data as a mechanism to help us function more effectively, and to act as a demonstrator of both the technical and policy challenges.

Our first 2-week sprint starts on 4th February. We're using [the issues](https://github.com/theodi/open-orgn-services/issues) to scope and track what we're doing.

Setup
-----

Configuration is loaded from environment variables. Copy env.example to .env 
and enter the appropriate details.

This app uses [resque](https://github.com/defunkt/resque) for async job queueing. 
You'll need to install redis, run it, and then run a worker to process jobs. On OSX:

    brew install redis
    redis-server &
    bundle
    VVERBOSE=1 QUEUE=* rake resque:work

Regular jobs are handled by the resque scheduler, which you can run like so:

    QUEUE=* rake resque:scheduler

To get a web interface on your resque workers:

    resque-web config/resque-web.rb

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