module Elasticfeed

  class Resource::Feed < Resource

    attr_accessor :name
    attr_accessor :entries_count
    attr_accessor :workflows_count
    attr_accessor :feed_data

    attr_accessor :entries
    attr_accessor :workflows

    def initialize
      @entries = []
      @workflows = []
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

    def workflows
      if @workflows.empty?
        @client.get('/application/' + app.id + '/feed/' + @id + '/workflow').each do |workflow|
          c = Elasticfeed::Resource::Workflow.new
          c.set_client(@client)
          c.set_data(workflow)
          @workflows.push c
        end
      end
      @workflows
    end

    def new_entry(data)
      data = {
        :Data => data
      }
      Elasticfeed::Resource::Entry.create(@client, @data['Application']['Id'], @id, data)
    end

    def new_workflow(data)
      data = {
        :Data => data
      }
      Elasticfeed::Resource::Workflow.create(@client, @data['Application']['Id'], @id, data)
    end

    def reload
      @client.get('/application/' + app.id + '/feed/' + @id + '/reload')
    end

    def empty
      @client.get('/application/' + app.id + '/feed/' + @id + '/empty')
    end

    def table_row
      [app.org.name, app.name, @name, @entries_count, @workflows_count, @feed_data]
    end

    def table_section
      [table_row]
    end

    def self.table_header
      ['Org', 'App', 'Feed', 'Entries', 'Workflows', 'Data']
    end

    def self._find(client, application_id, id)
      client.get('/application/' + application_id + '/feed/' + id)
    end

    private

    def _from_hash(data)
      @name = data['name'].nil? ? data['Id'] : data['name']
      @entries_count = data['Entries']
      @workflows_count = data['Workflows']
      @feed_data = data['Data']
    end

    def _to_hash
      @data
    end

  end
end
