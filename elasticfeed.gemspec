require File.expand_path('../lib/elasticfeed/version', __FILE__)

Gem::Specification.new do |s|
  s.name        = 'elasticfeed'
  s.version     = ELASTICFEED::VERSION
  s.summary     = 'Elasticfeed API client'
  s.description = 'Agent for Elasticfeed API'
  s.authors     = ['feedlabs', 'kris-lab']
  s.email       = 'hello@feedlabs.io'
  s.files       = Dir['LICENSE*', 'README*', '{bin,lib}/**/*']
  s.executables = ['elasticfeed']
  s.homepage    = 'https://github.com/feedlabs/sdk-ruby'
  s.license     = 'MIT'

  s.add_runtime_dependency 'net-http-digest_auth', '~> 1.4'
  s.add_runtime_dependency 'terminal-table', '~> 1.4.5'
  s.add_runtime_dependency 'parseconfig', '~> 1.0.6'
  s.add_runtime_dependency 'clamp', '~> 0.6.0'

  s.add_development_dependency 'rake'
  s.add_development_dependency 'rspec', '~> 2.0'
end
