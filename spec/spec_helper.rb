require 'bundler/setup'
require 'webmock/rspec'
require 'civic_sip'

Dir["#{File.expand_path(File.dirname(__FILE__))}/support/**/*.rb"].each { |f| require f }

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  # Clean up cached configuration after each spec
  config.after(:each) do
    if CivicSIP.instance_variable_defined? :@configuration
      CivicSIP.remove_instance_variable :@configuration
    end
  end
end
