# frozen_string_literal: true

require 'json'
require 'httparty'
require 'civic_sip_sdk/app_config'
require 'civic_sip_sdk/user_data'
require 'civic_sip_sdk/crypto'

module CivicSIPSdk
  class Client
    BASE_URL = 'https://api.civic.com/sip'
    AUTH_CODE_PATH = 'scopeRequest/authCode'
    PUBLIC_HEX = '049a45998638cfb3c4b211d72030d9ae8329a242db63bfb0076a54e7647370a8ac5708b57af6065805d5a6be72332620932dbb35e8d318fce18e7c980a0eb26aa1'
    MIMETYPE_JSON = 'application/json'

    ENV_VAR = 'CIVIC_SIP_SDK_ENV'
    TEST_ENV = 'test'

    HTTP_REQUEST_METHOD = 'POST'

    # Creates a client
    #
    # @param config [CivicSIPSdk::AppConfig] app_config that sets all the parameters of the client
    def initialize(config:)
      @config = config
      @test_env = ENV[ENV_VAR] == TEST_ENV
    end

    # Exchange authorization code in the form of a JWT Token for the user data
    # requested in the scope request.
    #
    # @param jwt_token [String] a JWT token that contains the authorization code
    # @return [CivicSIPSdk::UserData] user data returned from SIP
    def exchange_code(jwt_token:)
      json_body_str = JSON.generate('authToken' => jwt_token)

      response = HTTParty.post(
        "#{BASE_URL}/#{@config.env}/#{AUTH_CODE_PATH}",
        headers: {
          'Content-Type' => MIMETYPE_JSON,
          'Accept' => MIMETYPE_JSON,
          'Content-Length' => json_body_str.size.to_s,
          'Authorization' => authorization_header(body: json_body_str)
        },
        body: json_body_str
      )

      unless response.code == 200
        raise StandardError.new(
          "Failed to exchange JWT token. HTTP status: #{response.code}, response body: #{response.body}"
        )
      end

      res_payload = JSON.parse(response.body)
      extract_user_data(response: res_payload)
    end

    private

    def authorization_header(body:)
      jwt_token = Crypto.jwt_token(
        app_id: @config.id,
        sip_base_url: BASE_URL,
        data: {
          method: HTTP_REQUEST_METHOD,
          path: AUTH_CODE_PATH
        },
        private_key: @config.private_key
      )

      civic_extension = Crypto.civic_extension(secret: @config.secret, body: body)

      "Civic #{jwt_token}.#{civic_extension}"
    end

    def extract_user_data(response:)
      # only verify the token if it's in production (test is using an expired token)
      decoded_token = Crypto.decode_jwt_token(
        token: response['data'],
        public_hex_key: PUBLIC_HEX,
        should_verify: !@test_env
      )
      data_text = if response['encrypted']
                    # decrypt the data attr
                    Crypto.decrypt(
                      text: decoded_token['data'],
                      secret: @config.secret
                    )
                  else
                    decoded_data['data']
                  end

      UserData.new(
        user_id: response['userId'],
        data_items: JSON.parse(data_text)
      )
    end
  end
end
