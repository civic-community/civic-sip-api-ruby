RSpec.describe CivicSIP::Client do
  include SIPRequestHelpers

  describe '#exchange_code' do
    let(:signing_key_hex) { 'ec844af6422e1f3db7bdbf6443bd47ea9e58f31a708045a9b8c4f36a3987bad4' }
    let(:secret) { '50c0c3273d5a7ca8a04287f82c6d0111' }

    # Generate our own SIP key pair (so that we can sign and verify mocked SIP responses)
    let(:sip_key) do
      OpenSSL::PKey::EC.new('prime256v1').tap do |ecdsa_key|
        ecdsa_key.generate_key
      end
    end

    let(:user_data) do
      [
        {
          'label'   => 'contact.personal.email',
          'value'   => 'foo@example.com',
          'isValid' => true,
          'isOwner' => true
        },

        {
          'label'   => 'contact.personal.phoneNumber',
          'value'   => '+1 1235551234',
          'isValid' => true,
          'isOwner' => true
        }
      ]
    end

    before do
      # We normally use a hardcoded public key to verify signed SIP JWTs,
      # but we stub it out with the public key that's part of a key pair
      # that we generated, so that we can sign/verify mocked responses
      stub_const 'CivicSIP::Client::PUBLIC_KEY_HEX', sip_key.public_key.to_bn.to_s(16).downcase
    end

    subject { described_class.new 'app42', signing_key_hex, secret }

    context 'successful exchange' do
      let(:digest) do
        encoded_message_digest secret, { authToken: 'token42' }.to_json
      end

      # Create a JWT response token, signed with faked SIP key,
      # with encrypted user data payload (encrypted with app's secret)
      let!(:response_token) do
        sip_response_token encrypt(secret, user_data.to_json), sip_key
      end

      before do
        # Stub Time and SecureRandom to guarantee that our request token always looks the same

        # iat/exp depend on current time
        allow(Time).to receive(:now).and_return(Time.new(2018, 5, 4, 12))

        # JWT ID uses SecureRandom
        allow(SecureRandom).to receive(:hex) { '8634cbe609a2ffe273344573bf243a80' }
      end

      it 'makes request with proper Authorization header and decrypts and returns response' do
        # We have to stub the request JWT, because the signature includes a random component
        # This was created using the expected values, which are asserted below
        request_token = "eyJhbGciOiJFUzI1NiJ9.eyJpYXQiOjE1MjU0NDk2MDAsImV4cCI6MTUyNTQ0OTc4MCwiaXNzIjoiYXBwNDIiLCJhdWQiOiJodHRwczovL2FwaS5jaXZpYy5jb20vc2lwIiwic3ViIjoiYXBwNDIiLCJqdGkiOiI4NjM0Y2JlNjA5YTJmZmUyNzMzNDQ1NzNiZjI0M2E4MCIsImRhdGEiOlt7Im1ldGhvZCI6IlBPU1QiLCJwYXRoIjoic2NvcGVSZXF1ZXN0L2F1dGhDb2RlIn1dfQ._YlX9ENaUwRkwNLcffAUw8h3TJdWceVZZnbnogfbn_qS6kEs01-XTUBKMRSfJ9rJNV_7bzjsvtXvsewGzLcaGQ"

        expect(JWT).to receive(:encode) do |payload, key, algorithm|
          expect(payload).to eq(
            iat: Time.new(2018, 5, 4, 12).to_i,
            exp: (Time.new(2018, 5, 4, 12) + 60 * 3).to_i,
            iss: 'app42',
            aud: 'https://api.civic.com/sip',
            sub: 'app42',
            jti: '8634cbe609a2ffe273344573bf243a80',
            data: [
              method:  'POST',
              path:    'scopeRequest/authCode'
            ]
          )

          expect(key.private_key.to_s(16).downcase).to eq signing_key_hex

          expect(algorithm).to eq 'ES256'

          request_token
        end

        # Stub SIP request with expected headers,
        # and respond with a JWT with encrypted user data as its payload
        stub_request(
          :post,
          "https://api.civic.com/sip/prod/scopeRequest/authCode"
        ).with(
          headers: {
            'Accept'        => 'application/json',
            'Content-Type'  => 'application/json',
            'Authorization' => "Civic #{request_token}.#{digest}"
          },
          body: {
            authToken: 'token42'
          }.to_json
        ).to_return(
          status: 200,
          body: {
            data: response_token,
            userId: 'user-123',
            encrypted: true,
            alg: 'aes'
          }.to_json
        )

        expect(subject.exchange_code('token42')).to eq(
          userId: 'user-123',
          data: user_data
        )
      end
    end

    context 'unknown key used to sign response token' do
      let(:unknown_key) do
        OpenSSL::PKey::EC.new('prime256v1').tap do |ecdsa_key|
          ecdsa_key.generate_key
        end
      end

      # Sign response with a different/unknown key
      # (not the private key matching the stubbed SIP public key)
      let(:response_token) do
        sip_response_token encrypt(secret, user_data.to_json), unknown_key
      end

      it 'raises a JWT::VerificationError' do
        stub_request(
          :post,
          "https://api.civic.com/sip/prod/scopeRequest/authCode"
        ).to_return(
          status: 200,
          body: {
            data: response_token,
            userId: 'user-123',
            encrypted: true,
            alg: 'aes'
          }.to_json
        )

        expect { subject.exchange_code('token42') }.to raise_error(JWT::VerificationError)
      end
    end

    context 'non-200 API response' do
      it 'raises a CivicSIP::APIError with the response code and body' do
        stub_request(
          :post,
          "https://api.civic.com/sip/prod/scopeRequest/authCode"
        ).to_return(
          status: 400,
          body: '[Bad Request]: token failed verification'
        )

        expect { subject.exchange_code('token42') }.to raise_error do |error|
          expect(error).to be_a CivicSIP::APIError
          expect(error.http_code).to eq '400'
          expect(error.message).to eq '[Bad Request]: token failed verification'
        end
      end
    end
  end
end