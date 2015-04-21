module Elasticfeed

  class Agent

    attr_accessor :client

    # @param [Elasticfeed::Client] client
    def initialize(client)
      @client = client
    end

    # @param [String] apiurl
    def set_apiurl(apiurl)
      @client.url = apiurl
    end

    # @return [Array<Elasticfeed::Resource::Organisation>]
    def orgs
      org_list = []
      client.get('/org').each do |org|
        g = Elasticfeed::Resource::Organisation.new
        g.set_client(client)
        g.set_data(org)

        org_list.push g
      end
      org_list
    end

    # @return [Array<Elasticfeed::Resource::Plugin>]
    def plugins
      plugin_list = []
      client.get('/system/plugin').each do |org|
        g = Elasticfeed::Resource::Plugin.new
        g.set_client(client)
        g.set_data(org)

        plugin_list.push g
      end
      plugin_list
    end

    # @return [Array<Elasticfeed::Resource::Application>]
    def apps
      app_list = []
      client.get('/application').each do |application|
        g = Elasticfeed::Resource::Application.new
        g.set_client(client)
        g.set_data(application)

        app_list.push g
      end
      app_list
    end

    def feeds
      feed_list = []
      apps.each do |app|
        feed_list.concat app.feeds
      end
      feed_list
    end

    def entries
      entry_list = []
      feeds.each do |feed|
        entry_list.concat feed.entries
      end
      entry_list
    end

    def workflows
      workflow_list = []
      feeds.each do |feed|
        workflow_list.concat feed.workflows
      end
      workflow_list
    end

    # @return [Elasticfeed::Resource::Organisation]
    def find_organisation(id)
      Elasticfeed::Resource::Organisation.find(@client, id)
    end

    # @return [Elasticfeed::Resource::Plugin]
    def find_plugin(id)
      Elasticfeed::Resource::Plugin.find(@client, id)
    end

    # @return [Elasticfeed::Resource::Application]
    def find_application(id)
      Elasticfeed::Resource::Application.find(@client, id)
    end

  end
end
