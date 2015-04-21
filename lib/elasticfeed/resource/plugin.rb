module Elasticfeed

  class Resource::Plugin < Resource

    attr_reader :name
    attr_reader :group
    attr_reader :version
    attr_reader :status
    attr_reader :errors

    def table_row
      [@name, @id, @group, @version, @status, @errors]
    end

    def table_section
      [table_row]
    end

    def self.table_header
      ['Name', 'PluginId', 'Group', 'Version', 'Status', 'Errors']
    end

    def self._find(client, id)
      client.get('/system/plugin/' + id)
    end

    def delete
      @client.delete('/system/plugin/' + @id)
    end

    private

    def _from_hash(data)
      @name = data['name'].empty? ? data['id'] : data['name']
      @group = data['group']
      @version = data['version']
      @status = data['status']
      @errors = data['errors']
    end

    def _to_hash
      @data
    end
  end
end
