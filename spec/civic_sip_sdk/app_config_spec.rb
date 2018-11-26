# frozen_string_literal: true

require 'civic_sip_sdk/app_config'

RSpec.describe CivicSIPSdk::AppConfig do
  let(:dev_app_config) do
    {
      id: 'civic_app_1',
      env: :dev,
      private_key: 'a:private:key',
      secret: 'this:is:a:secret'
    }
  end

  let(:prod_app_config) do
    {
      id: 'civic_app_2',
      env: :prod,
      private_key: 'a:private:key',
      secret: 'this:is:a:secret'
    }
  end

  let(:bad_env_app_config) do
    {
      id: 'civic_app_3',
      env: :staging,
      private_key: 'a:private:key',
      secret: 'this:is:a:secret'
    }
  end

  context 'when valid args are passsed in' do
    it 'should not raise an error for a dev config' do
      expect { CivicSIPSdk::AppConfig.new(dev_app_config) }.to_not raise_error
    end

    it 'should not raise an error for a prod config' do
      expect { CivicSIPSdk::AppConfig.new(prod_app_config) }.to_not raise_error
    end

    it 'should not raise an error for a config without env' do
      expect { CivicSIPSdk::AppConfig.new(bad_env_app_config) }.to_not raise_error
    end
  end

  context 'when invalid args are passed in' do
    it 'should raise an ArgumentError if id is nil' do
      app_config = dev_app_config.merge(id: nil)
      expect { CivicSIPSdk::AppConfig.new(app_config) }.to raise_error(ArgumentError)
    end

    it 'should raise an ArgumentError if private_key is nil' do
      app_config = prod_app_config.merge(private_key: nil)
      expect { CivicSIPSdk::AppConfig.new(app_config) }.to raise_error(ArgumentError)
    end

    it 'should raise an ArgumentError if secret is nil' do
      app_config = bad_env_app_config.merge(secret: nil)
      expect { CivicSIPSdk::AppConfig.new(app_config) }.to raise_error(ArgumentError)
    end
  end
end
