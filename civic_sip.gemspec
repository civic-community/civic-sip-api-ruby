lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "civic_sip/version"

Gem::Specification.new do |spec|
  spec.name          = "civic_sip"
  spec.version       = CivicSIP::VERSION
  spec.authors       = ["Jim Ryan"]
  spec.email         = ["jim@room118solutions.com"]

  spec.summary       = %q{Interfaces with Civic's SIP service to exchange an authorization code for user data}
  spec.homepage      = "https://github.com/civic-community/civic-sip-api-ruby"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "bin"
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "jwt", ">= 2.1"

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "webmock", "~> 3.4.1"
end
