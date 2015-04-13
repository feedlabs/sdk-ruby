require 'elasticfeed'

describe Elasticfeed::Resource::Organisation do
  let(:client) { Elasticfeed::Client.new }

  it 'should load data' do
    client.stub(:get).and_return(
        {
            "id" => "1",
            "name" => "elasticfeed-org-1",
        }
    )

    group = Elasticfeed::Resource::Organisation.find(client, '1')

    group.id.should eq('1')
    group.name.should eq('elasticfeed-org-1')
    group.shard_count.should eq(2)
  end

end
