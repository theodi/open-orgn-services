# Open Organisation Services

This repository is for code for services that support the ODI's operation as an open organisation. Our aim is to publish open data as a mechanism to help us function more effectively, and to act as a demonstrator of both the technical and policy challenges.

Our first 2-week sprint starts on 4th February. We're using [the issues](https://github.com/theodi/open-orgn-services/issues) to scope and track what we're doing.

Setup
-----

This app uses resque for async job queueing. You'll need to install redis, run it, and then run a worker to process jobs. on OSX:

    brew install redis
		redis-server &
		bundle
		VVERBOSE=1 QUEUE=* rake resque:work
		
To get a web interface on your resque workers:

    resque-web -p 8282

There isn't currently a main point of entry for the app itself, though that will come along soon.

License
-------

This code is open source under the MIT license. See the LICENSE.md file for 
full details.