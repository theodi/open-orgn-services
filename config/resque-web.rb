$:.unshift File.join( File.dirname(__FILE__), "..", "lib")

require 'resque'

# Include resque scheduler stuff for web interface
require 'resque_scheduler'
require 'resque_scheduler/server'

require 'open-orgn-services'

Resque.schedule = YAML.load_file(File.join('config', 'schedule.yml'))