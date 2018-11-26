# frozen_string_literal: true

require 'json'
require 'civic_sip_sdk/crypto'

RSpec.describe CivicSIPSdk::Crypto do
  context 'AES crypto' do
    let(:secret) { '67b90124dae5cd46eba888705fcadb09' }
    let(:original) { 'top secret content' }

    before(:each) do
      @encrypted = CivicSIPSdk::Crypto.encrypt(text: original, secret: secret)
      @decrypted = CivicSIPSdk::Crypto.decrypt(text: @encrypted, secret: secret)
    end

    context 'when ecrypting' do
      it 'should successfully encrypt the text' do
        expect(@encrypted).to be_a(String)
      end

      it 'should encrypt the text to at least 32 chars in length' do
        expect(@encrypted.size).to be > 32
      end
    end

    context 'when decrypting' do
      it 'should decrypt to a string' do
        expect(@decrypted).to be_a(String)
      end

      it 'should match the original' do
        expect(@decrypted).to eq(original)
      end
    end
  end

  context 'JWT crypto' do
    let(:private_key) { 'a3ed0dd27cbfa62e13e340fb3dbb86895b99d5fd330a80e799baffcb1d29c17a' }
    let(:public_key) { '04a77e5c9c01df457ba941e28e187d3f53962f9038b5e481036cd9e7e9d1b1047c223c5b3db30fb12ff9f26eb229bb422eecf1a5df676d91099e081e4ec88ec339' }
    let(:secret) { '879946CE682C0B584B3ACDBC7C169473' }
    let(:app_id) { 'A4yZP9NOU' }
    let(:sip_base_url) { 'https://api.civic.com/sip/' }
    let(:data) { { 'email' => 'company.admin@example.com' } }

    before(:each) do
      @jwt_token = CivicSIPSdk::Crypto.jwt_token(
        app_id: app_id,
        sip_base_url: sip_base_url,
        data: data,
        private_key: private_key
      )
    end

    it 'should create a valid JWT token' do
      expect(@jwt_token).not_to be_nil
    end

    it 'should decrypt the token correctly' do
      decrypted = CivicSIPSdk::Crypto.decode_jwt_token(
        token: @jwt_token,
        public_hex_key: public_key,
        should_verify: false
      )
      expect(decrypted['data']).to eq(data)
    end
  end
end
