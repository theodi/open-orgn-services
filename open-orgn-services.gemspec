lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)
 
Gem::Specification.new do |s|
  s.name        = "open-orgn-services"
  s.version     = "0.0.0"
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["James Smith", "Sam Pikesley", "Tom Heath", "Stuart Harrison"]
  s.email       = ["tech@theodi.org"]
  s.homepage    = "http://github.com/theodi/open-orgn-services"
  s.summary     = "Reusable services that run the ODI's business logic"
 
  s.required_rubygems_version = ">= 1.8.24"

  s.add_dependency 'rake'               , '~> 10.0', '>= 10.0.3'
  s.add_dependency 'eventbrite-client'  , '~> 0.1' , '>= 0.1.4'
  s.add_dependency 'resque'             , '~> 1.23', '>= 1.23.0'
  s.add_dependency 'resque-scheduler'   , '~> 2.0' , '>= 2.0.0'
  s.add_dependency 'github_api'         , '~> 0.9' , '>= 0.9.0'
  s.add_dependency 'leftronicapi'       , '~> 1.2' , '>= 1.2.0'
  s.add_dependency 'activemodel'        , '~> 3.2' , '>= 3.2.12'
  s.add_dependency 'ruby-trello'        , '~> 0.5' , '>= 0.5.1'
  s.add_dependency 'jenkins-remote-api' , '~> 0.0' , '>= 0.0.4'
  s.add_dependency 'xeroizer'           , '~> 2.15', '>= 2.15.3'
  s.add_dependency 'capsulecrm'

  s.add_development_dependency 'cucumber'         , '~> 1.2' , '>= 1.2.1'
  s.add_development_dependency 'rspec'            , '~> 2.12', '>= 2.12.0'
  s.add_development_dependency 'vcr'              , '~> 2.4' , '>= 2.4.0'
  s.add_development_dependency 'webmock'          , '1.9.3'
  s.add_development_dependency 'dotenv'           , '~> 0.5' , '>= 0.5.0'
  s.add_development_dependency 'simplecov-rcov'   , '~> 0.2' , '>= 0.2.3'
  s.add_development_dependency 'guard-cucumber'   , '~> 1.3' , '>= 1.3.2'
  s.add_development_dependency 'guard-spork'      , '~> 1.4' , '>= 1.4.2'
  s.add_development_dependency 'rb-fsevent'       , '~> 0.9' , '>= 0.9.3'
  s.add_development_dependency 'relish'           , '~> 0.6' , '>= 0.6.0'
  s.add_development_dependency 'timecop'          , '~> 0.5' , '>= 0.5.9.2'

  s.files        = Dir.glob("{lib}/**/*") + %w(LICENSE.md README.md)
  s.require_path = 'lib'
end


