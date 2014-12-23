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
  s.add_dependency 'eventbrite-client'  , '~> 0.1' , '>= 0.1.3'
  s.add_dependency 'resque'             , '~> 1.23', '>= 1.23.0'
  s.add_dependency 'resque-scheduler'   , '~> 2.0' , '>= 2.0.0'
  s.add_dependency 'github_api'         , '~> 0.9' , '>= 0.9.0', '<= 0.10.1'
  s.add_dependency 'activemodel'        , '~> 3.2' , '>= 3.2.12'
  s.add_dependency 'ruby-trello'        , '~> 0.5' , '>= 0.5.1'
  s.add_dependency 'xeroizer'           , '~> 2.15', '>= 2.15.6'
  s.add_dependency 'capsulecrm'
  s.add_dependency 'fog'                , '~> 1.12', '>= 1.12.1'
  s.add_dependency 'httparty'
  s.add_dependency 'rufus-scheduler'    , '< 3.0.0'
  s.add_dependency 'pony'               , '~> 1.6' , '>= 1.6.2'
  s.add_dependency 'google_drive'       , '~> 0.3' , '>= 0.3.6'
  s.add_dependency 'curb'               , '~> 0.8' , '>= 0.8.6'

  s.files        = Dir.glob("{lib}/**/*") + %w(LICENSE.md README.md)
  s.require_path = 'lib'
end


