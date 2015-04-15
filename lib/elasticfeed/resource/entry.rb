module Elasticfeed

  class Resource::Entry < Resource

    attr_accessor :name
    attr_accessor :entry_data

    def initialize
      @entries = []
    end

    def feed
      Elasticfeed::Resource::Feed.find(@client, @data['Feed']['Application']['Id'], @data['Feed']['Id'])
    end

    def table_row
      [feed.app.org.name, feed.app.name, feed.name, @name, @entry_data]
    end

    def table_section
      [table_row]
    end

    def self.table_header
      ['Org', 'App', 'Feed', 'Entry', 'Data']
    end

    def self._find(client, application_id, feed_id, id)
      client.get('/application/' + application_id + '/feed/' + feed_id + '/entry/' + id)
    end

    private

    def _from_hash(data)
      @name = data['name'].nil? ? data['Id'] : data['name']
      @entry_data = data['Data']
    end

    def _to_hash
      @data
    end

  end
end
