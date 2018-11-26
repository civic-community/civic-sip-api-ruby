# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'civic_sip_sdk/version'

Gem::Specification.new do |spec|
  spec.name          = 'civic_sip_sdk'
  spec.version       = CivicSIPSdk::VERSION
  spec.authors       = ['Han Wang']
  spec.email         = ['han@binarystorms.com']

  spec.summary       = 'A ruby SDK for Civic SIP integration'
  spec.description   = 'A ruby SDK for Civic SIP integration'
  spec.homepage      = 'https://github.com/BinaryStorms/civic-sip-ruby-sdk'
  spec.license       = 'MIT'
  spec.required_ruby_version = '>= 2.1'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").select { |f| f.match(%r{^lib/}) }
  end

  spec.require_paths = ['lib']

  # dev dependencies
  spec.add_development_dependency 'bundler', '~> 1.16'
  spec.add_development_dependency 'coveralls', '~> 0.8.22'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'webmock', '~> 3.4'
  spec.add_development_dependency 'yard', '~> 0.9.16'
  # dependencies
  spec.add_dependency 'httparty', '~> 0.16'
  spec.add_dependency 'jwt', '2.1.0'
end
