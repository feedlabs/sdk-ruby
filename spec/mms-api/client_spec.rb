require 'elasticfeed'

describe Elasticfeed::Client do
  let(:client) { Elasticfeed::Client.new }

  it 'should return default api uri' do
    client.url.should eq('https://mms.mongodb.com:443/api/public/v1.0')
  end
end
