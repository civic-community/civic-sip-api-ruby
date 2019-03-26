require 'securerandom'
require 'net/http'
require 'jwt'

module CivicSIP
  class Client
    PUBLIC_KEY_HEX = '049a45998638cfb3c4b211d72030d9ae8329a242db63bfb0076a54e7647370a8ac5708b57af6065805d5a6be72332620932dbb35e8d318fce18e7c980a0eb26aa1'
    BASE_URL       = 'https://api.civic.com/sip'
    PATH           = 'scopeRequest/authCode'

    def initialize(app_id, private_signing_key, secret)
      @app_id              = app_id
      @private_signing_key = private_signing_key
      @secret              = secret
    end

    # Takes JWT retrieved from the Javascript SDK
    # and exchanges it for the user's ID and data
    #
    # The request header includes an Authorization header,
    # which looks like this: Civic <request jwt>.<message_digest>
    #
    # The <request jwt> is a JWT signed with the app's private signing key
    # that expires in 3 minutes and has a payload describing the API
    # endpoint being requested (POST to scopeRequest/authCode)
    #
    # The <message digest> is a base64 encoded HMAC SHA256 digest
    # of the request body created using the app's secret.
    #
    # A successful response from SIP is a JSON string that looks like this:
    # {
    #   data: <JWT>,
    #   userId: <user id>,
    #   encrypted: true
    #   alg: 'aes'
    # }
    #
    # <user id> is the requested user's ID
    #
    # <JWT> is a JWT signed using SIP's private key,
    # which we can verify using its public key, stored in PUBLIC_KEY_HEX.
    # The JWT's payload is the user's data, encrypted using AES and the app's secret.
    #
    # If we fail to verify the signature on the returned JWT,
    # we'll raise a JWT::VerificationError
    #
    # If the API responds with a non-200 status,
    # we'll raise a CivicSIP::APIError with the HTTP status code and response body.
    def exchange_code(token)
      response = Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
        http.request build_request(token)
      end

      if response.kind_of?(Net::HTTPSuccess)
        json = JSON.parse(response.body)

        {
          userId: json['userId'],
          data: JSON.parse(decrypted_token_data(json['data']))
        }
      else
        raise APIError.new(response.code, response.body)
      end
    end

    private

      def uri
        @uri ||= URI("#{BASE_URL}/prod/#{PATH}")
      end

      def ecdsa_signing_key
        OpenSSL::PKey::EC.new('prime256v1').tap do |ecdsa_key|
          ecdsa_key.private_key = OpenSSL::BN.new(@private_signing_key, 16)
        end
      end

      def request_token
        JWT.encode(
          {
            iat: Time.now.to_i,            # Issued at (now)
            exp: (Time.now + 60 * 3).to_i, # Expires at (3 minutes from now)
            iss: @app_id,                  # Issuer
            aud: BASE_URL,                 # Audience
            sub: @app_id,                  # Subject
            jti: SecureRandom.hex,         # ID
            data: [                        # Custom claim
              method: 'POST',
              path:   PATH
            ]
          },
          ecdsa_signing_key,
          'ES256'
        )
      end

      def digest_for(str)
        Base64.encode64(
          OpenSSL::HMAC.digest(
            OpenSSL::Digest.new('sha256'),
            @secret,
            str
          )
        )
      end

      def build_request(auth_token)
        body = {
          authToken: auth_token
        }.to_json

        headers = {
          'Accept'        => 'application/json',
          'Content-Type'  => 'application/json',
          'Authorization' => "Civic #{request_token}.#{digest_for(body)}"
        }

        Net::HTTP::Post.new(uri.request_uri, headers).tap do |request|
          request.body = body
        end
      end

      # Decrypts an encrypted SIP response using the app's secret.
      #
      # The first 32 characters are the hex representation of
      # the encrypted data's initialization vector.
      # The remaining characters are the encrypted data, base64 encoded.
      def decrypt(data)
        cipher = OpenSSL::Cipher::AES.new(128, :CBC)
        cipher.decrypt

        cipher.key = [@secret].pack('H*')
        cipher.iv  = [data[0..31]].pack('H*')

        cipher.update(Base64.decode64(data[32..-1])) + cipher.final
      end

      def sip_public_key
        OpenSSL::PKey::EC.new('prime256v1').tap do |ecdsa_key|
          ecdsa_key.public_key = OpenSSL::PKey::EC::Point.new(
            ecdsa_key.group,
            OpenSSL::BN.new(PUBLIC_KEY_HEX, 16)
          )
        end
      end

      # Accepts a response JWT, decodes it,
      # verifies its signature, and decrypts its payload.
      def decrypted_token_data(token)
        decoded_token = JWT.decode(token, sip_public_key, true, { 'algorithm': 'ES256' })

        decrypt decoded_token[0]['data']
      end
  end
end