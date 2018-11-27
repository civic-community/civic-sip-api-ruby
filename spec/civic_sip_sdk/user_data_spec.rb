# frozen_string_literal: true

require 'civic_sip_sdk/user_data'
require 'civic_sip_sdk/user_data_item'

RSpec.describe CivicSIPSdk::UserData do
  let(:raw_user_data_items) do
    [
      {
        'label' => 'user.email',
        'value' => 'big.boss@example.com',
        'isValid' => true,
        'isOwner' => true
      },
      {
        'label' => 'user.firstName',
        'value' => 'William',
        'isValid' => false,
        'isOwner' => true
      }
    ]
  end

  before(:each) do
    @user_data = CivicSIPSdk::UserData.new(
      user_id: 'user123',
      data_items: raw_user_data_items
    )
  end

  it 'should return a valid instance of UserData' do
    expect(@user_data).to be_a(CivicSIPSdk::UserData)
  end

  it 'should return valid data from attr readers' do
    expect(@user_data.user_id).to eq('user123')
    expect(@user_data.data_items).to eq(raw_user_data_items)
  end

  it 'should return correct user data by label' do
    user_data_item = @user_data.by_label(label: 'user.email')
    expect(user_data_item).to be_a(CivicSIPSdk::UserDataItem)
    expect(user_data_item.label).to eq('user.email')
    expect(user_data_item.value).to eq('big.boss@example.com')
    expect(user_data_item.is_valid).to be_truthy
    expect(user_data_item.is_owner).to be_truthy
  end

  it 'should return nil if user data item label does not exist' do
    expect(@user_data.by_label(label: 'not.here')).to be_nil
  end
end
