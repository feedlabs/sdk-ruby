module Elasticfeed

  class Resource::Plugin < Resource

    attr_reader :name

    def table_row
      [@name, @id]
    end

    def table_section
      [table_row]
    end

    def self.table_header
      ['Name', 'PluginId']
    end

    def self._find(client, id)
      client.get('/system/plugin/' + id)
    end

    private

    def _from_hash(data)
      @name = data['name'].empty? ? data['id'] : data['name']
    end

    def _to_hash
      @data
    end
  end
end
