module SIPRequestHelpers
  # Given a String hex key and some String data,
  # encrypts with aes-128-cbc and returns
  # a String with the iv as a hex string
  # followed by the encrypted data base64 encoded
  # (this is how SIP returns the encrypted user data)
  def encrypt(hex_key, data)
    cipher = OpenSSL::Cipher::AES.new(128, :CBC)
    cipher.encrypt

    iv = cipher.random_iv

    cipher.key = [hex_key].pack('H*')

    encrypted = cipher.update(data) + cipher.final

    "#{iv.unpack('H*')[0]}#{Base64.encode64(encrypted)}"
  end

  # Encodes/signs a JWT similar to how SIP does
  def sip_response_token(data, key, app_id)
    JWT.encode(
      {
        jti: SecureRandom.hex,
        iat: Time.now.to_i,
        exp: (Time.now + 60 * 30).to_i,
        iss: 'civic-sip-hosted-service',
        aud: 'https://api.civic.com/sip/',
        sub: app_id,
        data: data
      },
      key,
      'ES256'
    )
  end

  # Base64 encoded HMAC sha256 message digest of the given body using given key
  def encoded_message_digest(key, body)
    Base64.encode64(
      OpenSSL::HMAC.digest(
        OpenSSL::Digest.new('sha256'),
        key,
        body
      )
    ).strip
  end
end