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

    # @return [Elasticfeed::Resource::Organisation]
    def find_organisation(id)
      Elasticfeed::Resource::Organisation.find(@client, id)
    end

    # @return [Elasticfeed::Resource::Application]
    def find_application(id)
      Elasticfeed::Resource::Application.find(@client, id)
    end

  end
end
