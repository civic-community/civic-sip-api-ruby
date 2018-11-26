# frozen_string_literal: true

require 'civic_sip_sdk/user_data_item'

RSpec.describe CivicSIPSdk::UserDataItem do
  let(:user_data_item) do
    CivicSIPSdk::UserDataItem.new(
      label: 'user.email',
      value: 'company.owner@example.com',
      is_valid: true,
      is_owner: true
    )
  end

  it 'should return all correct values via attr reader' do
    expect(user_data_item.label).to eq('user.email')
    expect(user_data_item.value).to eq('company.owner@example.com')
    expect(user_data_item.is_valid).to eq(true)
    expect(user_data_item.is_owner).to eq(true)
  end
end
