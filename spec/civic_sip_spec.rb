RSpec.describe CivicSIP do
  describe 'configuration' do
    it 'yields configuration object to block and stores configuration' do
      CivicSIP.configure do |config|
        config.private_signing_key = 'private'
        config.secret              = 'secret'
        config.app_id              = '4242'
      end

      expect(CivicSIP.configuration.private_signing_key).to eq 'private'
      expect(CivicSIP.configuration.secret).to eq 'secret'
      expect(CivicSIP.configuration.app_id).to eq '4242'
    end
  end

  describe '#exchange_code' do
    before do
      CivicSIP.configure do |config|
        config.private_signing_key = '1234'
        config.secret              = '5678'
        config.app_id              = 'app1'
      end
    end

    it 'creates new Client and exchanges given token' do
      client = double(CivicSIP::Client)

      expect(CivicSIP::Client).to receive(:new).with('app1', '1234', '5678').and_return(client)

      expect(client).to receive(:exchange_code).with('jwttoken').and_return({ userId: '42', data: [] })

      expect(CivicSIP.exchange_code('jwttoken')).to eq({ userId: '42', data: [] })
    end
  end
end
