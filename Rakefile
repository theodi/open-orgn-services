$:.unshift File.join( File.dirname(__FILE__), "lib")

require 'rubygems'
require 'cucumber'
require 'cucumber/rake/task'
require 'coveralls/rake/task'
require 'rspec/core/rake_task'

Coveralls::RakeTask.new
RSpec::Core::RakeTask.new(:spec)

Cucumber::Rake::Task.new(:features) do |t|
  t.cucumber_opts = "features --format pretty"
end

task :default => [:spec, :features, :'coveralls:push']
