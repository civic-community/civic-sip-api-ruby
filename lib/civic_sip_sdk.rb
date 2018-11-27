# frozen_string_literal: true

$LOAD_PATH.unshift('lib')

require 'civic_sip_sdk/app_config'
require 'civic_sip_sdk/client'

module CivicSIPSdk
  module_function

  # Creates an instance of +CivicSIPSdk::Client+
  #
  # @param id [String] the Civic application id
  # @param env [Symbol] the Civic application environment
  # @param private_key [String] the Civic private signing key
  # @param secret [String] the Civic application secret
  # @return [CivicSIPSdk::Client] the client to exchange the JWT code for user data
  def new_client(id, env, private_key, secret)
    app_config = AppConfig.new(
      id: id,
      env: env,
      private_key: private_key,
      secret: secret
    )

    Client.new(config: app_config)
  end
end
