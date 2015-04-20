module Elasticfeed

  class Resource::Workflow < Resource

    attr_accessor :name
    attr_accessor :workflow_data

    def feed
      Elasticfeed::Resource::Feed.find(@client, @data['Feed']['Application']['Id'], @data['Feed']['Id'])
    end

    def table_row
      [feed.app.org.name, feed.app.name, feed.name, @name, @workflow_data]
    end

    def table_section
      [table_row]
    end

    def self.table_header
      ['Org', 'App', 'Feed', 'Workflow', 'Data']
    end

    def self._find(client, application_id, feed_id, id)
      client.get('/application/' + application_id + '/feed/' + feed_id + '/workflow/' + id)
    end

    def self._create(client, application_id, feed_id, data)
      client.post('/application/' + application_id + '/feed/' + feed_id + '/workflow', data)
    end

    def upload(data)
      data = {
        :Data => data
      }
      @client.put('/application/' + feed.app.id + '/feed/' + feed.id + '/workflow/' + @id, data)
    end

    def delete
      @client.delete('/application/' + feed.app.id + '/feed/' + feed.id + '/workflow/' + @id)
    end

    private

    def _from_hash(data)
      @name = data['name'].nil? ? data['Id'] : data['name']
      @workflow_data = data['Data']
    end

    def _to_hash
      @data
    end

  end
end
