$:.unshift File.join( File.dirname(__FILE__), "lib")

require 'rubygems'
require 'cucumber'
require 'cucumber/rake/task'
require 'resque/tasks'

Cucumber::Rake::Task.new(:features) do |t|
  t.cucumber_opts = "features --format pretty"
end

task :default => [:features]

namespace :resque do
  task :setup do
    require 'attendee_invoicer'
  end
end