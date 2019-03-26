require 'civic_sip/version'
require 'civic_sip/configuration'
require 'civic_sip/api_error'
require 'civic_sip/client'

module CivicSIP
  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.configure
    yield configuration
  end

  def self.exchange_code(token)
    Client.new(
      configuration.app_id,
      configuration.private_signing_key,
      configuration.secret
    ).exchange_code token
  end
end