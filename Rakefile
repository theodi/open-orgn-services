$:.unshift File.join( File.dirname(__FILE__), "lib")

require 'rubygems'
require 'cucumber'
require 'cucumber/rake/task'
require 'resque/tasks'
require 'resque_scheduler/tasks'

Cucumber::Rake::Task.new(:features) do |t|
  t.cucumber_opts = "features --format pretty"
end

task :default => [:features]

namespace :resque do
  task :setup do
    require 'resque'
    require 'resque_scheduler'
    require 'resque/scheduler'
    require 'open-orgn-services'
    # Load schedule
    Resque.schedule = YAML.load_file('config/schedule.yml')
  end
end