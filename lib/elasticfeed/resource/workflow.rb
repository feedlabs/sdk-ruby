module Elasticfeed

  class Resource::Workflow < Resource

    attr_reader :name
    attr_reader :workflow_data
    attr_reader :defualt
    attr_reader :status
    attr_reader :errors

    def feed
      Elasticfeed::Resource::Feed.find(@client, @data['applicationId'], @data['feedId'])
    end

    def table_row
      [feed.app.org.name, feed.app.name, feed.name, @name, @default, @status, @errors, @workflow_data]
    end

    def table_section
      [table_row]
    end

    def self.table_header
      ['Org', 'App', 'Feed', 'Workflow', 'Default', 'Status', 'Errors', 'Data']
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
      @name = data['name'].nil? ? data['id'] : data['name']
      @workflow_data = data['data']
      @default = data['default']
      @status = data['status']
      @errors = data['errors']
    end

    def _to_hash
      @data
    end

  end
end
