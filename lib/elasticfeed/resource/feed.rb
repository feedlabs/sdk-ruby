module Elasticfeed

  class Resource::Feed < Resource

    attr_accessor :name

    attr_accessor :entries

    def initialize
      @entries = []
    end

    def app
      Elasticfeed::Resource::Application.find(@client, @data['Application']['Id'])
    end

    def table_row
      [app.org.name, app.name, @name]
    end

    def table_section
      [table_row]
    end

    def self.table_header
      ['Org', 'App', 'Feed']
    end

    def self._find(client, application_id, id)
      client.get('/application/' + application_id + '/feed/' + id)
    end

    private

    def _from_hash(data)
      @name = data['name'].nil? ? data['Id'] : data['name']
    end

    def _to_hash
      @data
    end

  end
end
