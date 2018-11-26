# frozen_string_literal: true

require 'json'
require 'httparty'
require 'civic_sip_sdk/app_config'
require 'civic_sip_sdk/user_data'
require 'civic_sip_sdk/crypto'
require 'civic_sip_sdk/client'

RSpec.describe CivicSIPSdk::Client do
  let(:private_key) { 'bf5efd7bdde29dc28443614bfee78c3d6ee39c71e55a0437eee02bf7e3647721' }
  let(:secret) { '44bbae32d1e02bf481074177002bbdef' }
  let(:api_endpoint) { 'https://kw9lj3a57c.execute-api.us-east-1.amazonaws.com' }
  let(:env) { 'dev' }
  let(:bucket_response) do
    'eyJhbGciOiJFUzI1NiIsInR5cCI6IkpXVCJ9.eyJqdGkiOiI1OTYzNWQ2Yy0zYzUyLTQwMzktOTg2OS05MWQwMjUz' \
    'N2M2YjIiLCJpYXQiOjE1MTk5MzI1NzIuMTU4LCJleHAiOjE1MTk5MzQzNzIuMTU4LCJpc3MiOiJjaXZpYy1zaXAtaG9zdGVkLXNlcnZpY2UiLCJhd' \
    'WQiOiJodHRwczovL2FwaS5jaXZpYy5jb20vc2lwLyIsInN1YiI6Ikh5aGFXTzFTRyIsImRhdGEiOiI0MDNkNjI0MzY1OTYwMjIyYmQzMWE2MWNhMj' \
    'QzNWYyY1dOWjhrWkNEUWZWQmtSSVdsbDkzNGhZbDRUTGlrWWVENU52WE0xTUowN2FVQzFtcnFmdVdoWk5qQWVKT1plS0M2emk5Umh3cWR0bkswdWx' \
    'NRFAwTkRaTHBRa2JqaVdBb1c5RXFYQW41eHNyemZSNUZ0cXZqZ0NORzNvUkp0Y29tRVBvaGVWMDZ3NWZDQ0Z1TjQrbTNiSW5CNldMamNBSmVObUJZ' \
    'T2oyWjFFQVoxcHZ0R2RwSThMWTVYS2VFTHpKM3MzZndidEpXbkorSHFqakxsQjJPM0lmaDBRdVdUMldUNWVrc3RLN1F1bk5MSldiSzJqWkkveGc0R' \
    'HJFWFl0dnEifQ.YBBljiXaqrbiftAhu6X6csDVbRLcsSNf3xZNRgQzj6Wd7v1Ilja55H_K_gO7zFzj3Qi-bc7-83SI1w6A4Y7MEA'
  end
  let(:app_config) do
    CivicSIPSdk::AppConfig.new(
      id: 'HyhaWO1SG',
      env: env,
      private_key: private_key,
      secret: secret
    )
  end

  let(:client) { CivicSIPSdk::Client.new(config: app_config) }

  context 'during a successful exchange_code' do
    before(:each) do
      @auth_code = 'eyJhbGciOiJFUzI1NiIsInR5cCI6IkpXVCJ9.eyJqdGkiOiIxNzc1ZDQwMi05ZjNjLTQ0OWUtYWZkYS04ZDk4MmM0OGIxYjIiLCJpYXQiOjE1MTk5MzE3MTcuMDM1LCJleHAiOjE1MTk5MzM1MTcuMDM1LCJpc3MiOiJjaXZpYy1zaXAtaG9zdGVkLXNlcnZpY2UiLCJhdWQiOiJodHRwczovL2FwaS5jaXZpYy5jb20vc2lwLyIsInN1YiI6Ikh5aGFXTzFTRyIsImRhdGEiOnsiY29kZVRva2VuIjoiYTRhYjE1MDEtZTg0Ni00NmUyLWEwZDktMzEyNTAwNmIxNzUzIn19.1d3Q3QeL8SE_wlyxHPi6Pn-buf8XsxRlCkfhULiI5CbDLCgEjLuVMGIFSUXg6_snXOD9p-ImVml-0yF-A2-qaw'
      @response = 'eyJhbGciOiJFUzI1NiIsInR5cCI6IkpXVCJ9.eyJqdGkiOiI1OTYzNWQ2Yy0zYzUyLTQwMzktOTg2OS05MWQwMjUzN2M2YjIiLCJpYXQiOjE1MTk5MzI1NzIuMTU4LCJleHAiOjE1MTk5MzQzNzIuMTU4LCJpc3MiOiJjaXZpYy1zaXAtaG9zdGVkLXNlcnZpY2UiLCJhdWQiOiJodHRwczovL2FwaS5jaXZpYy5jb20vc2lwLyIsInN1YiI6Ikh5aGFXTzFTRyIsImRhdGEiOiI0MDNkNjI0MzY1OTYwMjIyYmQzMWE2MWNhMjQzNWYyY1dOWjhrWkNEUWZWQmtSSVdsbDkzNGhZbDRUTGlrWWVENU52WE0xTUowN2FVQzFtcnFmdVdoWk5qQWVKT1plS0M2emk5Umh3cWR0bkswdWxNRFAwTkRaTHBRa2JqaVdBb1c5RXFYQW41eHNyemZSNUZ0cXZqZ0NORzNvUkp0Y29tRVBvaGVWMDZ3NWZDQ0Z1TjQrbTNiSW5CNldMamNBSmVObUJZT2oyWjFFQVoxcHZ0R2RwSThMWTVYS2VFTHpKM3MzZndidEpXbkorSHFqakxsQjJPM0lmaDBRdVdUMldUNWVrc3RLN1F1bk5MSldiSzJqWkkveGc0RHJFWFl0dnEifQ.YBBljiXaqrbiftAhu6X6csDVbRLcsSNf3xZNRgQzj6Wd7v1Ilja55H_K_gO7zFzj3Qi-bc7-83SI1w6A4Y7MEA'

      stub_request(:post, /api.civic.com/)
        .to_return(
          status: 200,
          body: JSON.generate(
            'data' => @response,
            'userId' => '0eb98e188597a61ee90969a42555ded28dcdddccc6ffa8d8023d8833b0a10991',
            'encrypted' => true,
            'alg' => 'aes'
          )
        )
    end

    it 'should exchange an encrypted code with an instance of UserData' do
      expect(client.exchange_code(jwt_token: @auth_code)).to be_a(CivicSIPSdk::UserData)
    end

    it 'should return the user data with correct user id' do
      expect(client.exchange_code(jwt_token: @auth_code).user_id).to eq('0eb98e188597a61ee90969a42555ded28dcdddccc6ffa8d8023d8833b0a10991')
    end

    it 'should return 2 user data items' do
      expect(client.exchange_code(jwt_token: @auth_code).data_items.size).to eq(2)
    end

    it 'should return contact.personal.email correctly' do
      user_data_item = client.exchange_code(jwt_token: @auth_code).by_label(label: 'contact.personal.email')
      expect(user_data_item).to_not be_nil
      expect(user_data_item.label).to eq('contact.personal.email')
      expect(user_data_item.value).to eq('stephen@civic.com')
      expect(user_data_item.is_valid).to eq(true)
      expect(user_data_item.is_owner).to eq(true)
    end

    it 'should return contact.personal.phoneNumber correctly' do
      user_data_item = client.exchange_code(jwt_token: @auth_code).by_label(label: 'contact.personal.phoneNumber')
      expect(user_data_item).to_not be_nil
      expect(user_data_item.label).to eq('contact.personal.phoneNumber')
      expect(user_data_item.value).to eq('+1 4156804302')
      expect(user_data_item.is_valid).to eq(true)
      expect(user_data_item.is_owner).to eq(true)
    end
  end
end
