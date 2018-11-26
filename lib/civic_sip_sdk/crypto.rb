# frozen_string_literal: true

require 'base64'
require 'securerandom'
require 'openssl'
require 'jwt'

module CivicSIPSdk
  module Crypto
    CIPHER_ALGO = 'AES-128-CBC'
    IV_STRING_LENGTH = 32
    # "prime256v1" is another name for "secp256r1"
    ECDSA_CURVE = 'prime256v1'
    JWT_ALGO = 'ES256'
    HMAC_DIGEST = 'SHA256'

    # Create encrypted text using AES-128-CBC with a IV of 16 bytes
    #
    # @param text [String] the plain text to be encrypted
    # @param secret [String] the Civic application secret in HEX format
    def self.encrypt(text:, secret:)
      cipher = OpenSSL::Cipher.new(CIPHER_ALGO)
      cipher.encrypt
      cipher.key = hex_to_string(hex: secret)
      iv = cipher.random_iv
      cipher.iv = iv

      encrypted_text = "#{cipher.update(text)}#{cipher.final}"
      "#{string_to_hex(str: iv)}#{Base64.encode64(encrypted_text)}"
    end

    # Decrypt the encrypted text using AES-128-CBC with a IV of 32 bytes
    #
    # @param text [String] the encrypted text to be decrypted
    # @param secret [String] the Civic application secret in HEX format
    def self.decrypt(text:, secret:)
      cipher = OpenSSL::Cipher.new(CIPHER_ALGO)
      cipher.decrypt
      cipher.key = hex_to_string(hex: secret)
      iv_hex = text[0..(IV_STRING_LENGTH - 1)]
      cipher.iv = hex_to_string(hex: iv_hex)
      encrypted_text = Base64.decode64(text[IV_STRING_LENGTH..-1])

      "#{cipher.update(encrypted_text)}#{cipher.final}"
    end

    def self.jwt_token(app_id:, sip_base_url:, data:, private_key:)
      now = Time.now.to_i

      payload = {
        iat: now,
        exp: now + 60 * 3,
        iss: app_id,
        aud: sip_base_url,
        sub: app_id,
        jti: SecureRandom.uuid,
        data: data
      }

      JWT.encode(
        payload,
        private_signing_key(private_hex_key: private_key),
        JWT_ALGO
      )
    end

    def self.decode_jwt_token(token:, public_hex_key:, should_verify:)
      public_key = public_signing_key(public_hex_key: public_hex_key)
      data, = JWT.decode(token, public_key, should_verify, algorithm: JWT_ALGO)

      data
    end

    def self.civic_extension(secret:, body:)
      hmac = OpenSSL::HMAC.digest(HMAC_DIGEST, secret, JSON.generate(body))
      Base64.encode64(hmac)
    end

    class << self
      private

      def private_signing_key(private_hex_key:)
        key = OpenSSL::PKey::EC.new(ECDSA_CURVE)
        key.private_key = OpenSSL::BN.new(private_hex_key.to_i(16))

        key
      end

      def public_signing_key(public_hex_key:)
        group = OpenSSL::PKey::EC::Group.new(ECDSA_CURVE)
        point = OpenSSL::PKey::EC::Point.new(
          group,
          OpenSSL::BN.new(public_hex_key.to_i(16))
        )
        key = OpenSSL::PKey::EC.new(ECDSA_CURVE)
        key.public_key = point

        key
      end

      def string_to_hex(str:)
        str.unpack1('H*')
      end

      def hex_to_string(hex:)
        hex.scan(/../).map(&:hex).pack('c*')
      end
    end
  end
end
