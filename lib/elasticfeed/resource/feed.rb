module Elasticfeed

  class Resource::Feed < Resource

    attr_accessor :name
    attr_accessor :entries_count
    attr_accessor :feed_data

    attr_accessor :entries

    def initialize
      @entries = []
    end

    def app
      Elasticfeed::Resource::Application.find(@client, @data['Application']['Id'])
    end

    def entries
      if @entries.empty?
        @client.get('/application/' + app.id + '/feed/' + @id + '/entry').each do |entry|
          c = Elasticfeed::Resource::Entry.new
          c.set_client(@client)
          c.set_data(entry)
          @entries.push c
        end
      end
      @entries
    end

    def table_row
      [app.org.name, app.name, @name, @entries_count, @feed_data]
    end

    def table_section
      [table_row]
    end

    def self.table_header
      ['Org', 'App', 'Feed', 'Entries Count', 'Data']
    end

    def self._find(client, application_id, id)
      client.get('/application/' + application_id + '/feed/' + id)
    end

    private

    def _from_hash(data)
      @name = data['name'].nil? ? data['Id'] : data['name']
      @entries_count = data['Entries']
      @feed_data = data['Data']
    end

    def _to_hash
      @data
    end

  end
end
