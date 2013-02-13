worker:    bundle exec rake resque:work TERM_CHILD=1 QUEUE=*
scheduler: bundle exec rake resque:scheduler
web:       bundle exec resque-web -L -F -s thin config/resque-web.rb 
