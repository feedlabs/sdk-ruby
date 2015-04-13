module Elasticfeed

  class Resource::Application < Resource

    attr_accessor :name

    attr_accessor :feeds

    def initialize
      @feeds = []
    end

    def org
      Elasticfeed::Resource::Organisation.find(@client, @data['Org']['Id'])
    end

    def table_row
      [org.name, @name]
    end

    def table_section
      [table_row]
    end

    def self.table_header
      ['Org', 'App']
    end

    def self._find(client, id)
      client.get('/application/' + id)
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
