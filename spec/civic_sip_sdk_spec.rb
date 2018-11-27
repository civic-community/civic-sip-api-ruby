# frozen_string_literal: true

require 'civic_sip_sdk'
require 'civic_sip_sdk/client'

RSpec.describe CivicSIPSdk do
  it 'should return an instance of the client' do
    expect(CivicSIPSdk.new_client('abc', :dev, 'private_key', 'a secret'))
      .to be_a(CivicSIPSdk::Client)
  end
end
