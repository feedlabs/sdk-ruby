module Elasticfeed

  class Resource::Organisation < Resource

    attr_reader :name

    attr_accessor :applications

    def initialize
      @applications = []
    end

    # @param [Integer] page
    # @param [Integer] limit
    # @return [Array<Elasticfeed::Resource::Application>]
    def applications(page = 1, limit = 1000)
      if @applications.empty?
        @client.get('/application').each do |cluster|
          c = Elasticfeed::Resource::Application.new
          c.set_client(@client)
          c.set_data(cluster)
          @applications.push c
        end
      end
      @applications
    end

    # @param [String] id
    # @return [Elasticfeed::Resource::Application]
    def application(id)
      Elasticfeed::Resource::App.find(@client, @id, id)
    end

    def table_row
      [@name, @id]
    end

    def table_section
      [table_row]
    end

    def self.table_header
      ['Name', 'OrgId']
    end

    def self._find(client, id)
      client.get('/org/' + id)
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
