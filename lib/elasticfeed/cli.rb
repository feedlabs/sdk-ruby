require 'clamp'
require 'parseconfig'

module Elasticfeed

  class CLI

    class Elasticfeed::CLI::Command < Clamp::Command

      attr_accessor :app_name
      attr_accessor :config

      attr_accessor :client
      attr_accessor :agent

      option ['-u', '--username'], '<string>', 'Elasticfeed user' do |u|
        @config.username = u
      end

      option ['-k', '--apikey'], '<string>', 'Elasticfeed api-key' do |a|
        @config.apikey = a
      end

      option ['-a', '--apiurl'], '<string>', 'Elasticfeed api url. Full url including version: https://Elasticfeed.mydomain.tld/api/public/v1.0' do |u|
        @config.apiurl = u
      end

      option ['-v', '--version'], :flag, 'Version' do |v|
        puts "Elasticfeed-cli v#{Elasticfeed::VERSION}"
        exit
      end

      option ['-g', '--default-org-id'], '<string>', 'Default Elasticfeed organisation id' do |g|
        @config.default_org_id = g
      end

      option ['-c', '--default-app-id'], '<string>', 'Default Elasticfeed application id' do |c|
        @config.default_app_id = c
      end

      option ['-f', '--default-feed-id'], '<string>', 'Default Elasticfeed feed id' do |f|
        @config.default_feed_id = f
      end

      option ['--cfg'], '<string>', 'Config file path' do |p|
        @config.config_path = p
        parse_user_home_config
      end

      option ['-i', '--ignore'], :flag, 'Ignore flag of --org-id and -app-id', :default => false

      option ['-j', '--json'], :flag, 'Print JSON output', :default => false

      option ['-l', '--limit'], '<integer>', 'Limit for result items' do |l|
        @config.limit = Integer(l)
      end

      def initialize(invocation_path, context = {}, parent_attribute_values = {})
        @config ||= Elasticfeed::Config.new
      end

      def parse_user_home_config
        raise(Elasticfeed::ConfigError.new('Config file path is not set!')) if @config.config_path.nil?
        config_file = Pathname.new(@config.config_path)
        raise(Elasticfeed::ConfigError.new("Config file `#{config_file}` does not exist")) unless config_file.exist?

        config = ParseConfig.new(config_file)
        config.params.map do |key, value|
          begin
            @config.send("#{key}=", value)
          rescue Exception => e
            raise Elasticfeed::ConfigError.new("Config option `#{key}` from file `#{config_file}` is not allowed!")
          end
        end
      end

      # @return [Elasticfeed::Agent]
      def agent
        @client = Elasticfeed::Client.new(@config.username, @config.apikey, url=@config.apiurl)
        @agent = Elasticfeed::Agent.new(client)
      end

      # @return [Elasticfeed<Elasticfeed::Resource::Organisation>]
      def organisations
        id = ignore? ? nil : @config.default_org_id
        id.nil? ? agent.orgs : [agent.find_organisation(id)]
      end

      # @return [Elasticfeed<Elasticfeed::Resource::Application>]
      def applications
        id = ignore? ? nil : @config.default_app_id
        id.nil? ? agent.apps : [agent.find_application(id)]
      end

      # @param [String] heading
      # @param [Elasticfeed<Elasticfeed::Resource>]
      def print(heading, resource_list)
        json? ? print_json(resource_list) : print_human(heading, resource_list)
      end

      # @param [String] heading
      # @param [Elasticfeed<Elasticfeed::Resource>]
      def print_human(heading, resource_list)
        rows = []

        resource_list.first(@config.limit).each do |resource|
          rows += resource.table_section
        end

        puts Terminal::Table.new :headings => (heading.nil? ? [] : heading), :rows => rows

        print_tips unless ignore?
      end

      # @param [Elasticfeed<Elasticfeed::Resource>]
      def print_json(resource_list)
        rows = []

        resource_list.first(@config.limit).each do |resource|
          rows.push(resource.to_hash)
        end

        puts JSON.pretty_generate(rows)
      end

      def print_tips
        puts 'Default org: ' + @config.default_org_id unless @config.default_org_id.nil?
        puts 'Default app: ' + @config.default_app_id unless @config.default_app_id.nil?
        puts 'Default feed: ' + @config.default_feed_id unless @config.default_feed_id.nil?

        if !@config.default_org_id.nil? or !@config.default_app_id.nil?
          puts "Add flag --ignore or update --default-org-id, --default-app-id, --default-feed-id or update your `#{@config.config_path}` to see all resources"
        end
      end


      # @param [Array] arguments
      def run(arguments)
        begin
          parse_user_home_config
          super
        rescue Clamp::HelpWanted => e
          raise(help)
        rescue Clamp::UsageError => e
          raise([e.message, help].join("\n"))
        rescue Elasticfeed::AuthError => e
          raise('Authorisation problem. Please check you credential!')
        rescue Elasticfeed::ResourceError => e
          raise(["Resource #{e.resource.class.name} problem:", e.message].join("\n"))
        end
      end
    end

    class Elasticfeed::CLI::Command::Organisations < Elasticfeed::CLI::Command

      subcommand 'list', 'Organisation list' do

        def execute
          print(Elasticfeed::Resource::Organisation.table_header, organisations)
        end
      end

    end

    class Elasticfeed::CLI::Command::Applications < Elasticfeed::CLI::Command

      subcommand 'list', 'Applications list' do

        def execute
          print(Elasticfeed::Resource::Application.table_header, applications)
        end
      end

    end

    class Elasticfeed::CLI::Command::Feeds < Elasticfeed::CLI::Command

      subcommand 'list', 'Feeds list' do

        def execute
          feed_list = applications.collect! { |application| application.feeds }.flatten
          print(Elasticfeed::Resource::Feed.table_header, feed_list)
        end
      end

    end

    class Elasticfeed::CLI::CommandManager < Elasticfeed::CLI::Command

      def run(arguments)
        # begin
          super
        # rescue Exception => e
        #   abort(e.message.empty? ? 'Unknown error/Interrupt' : e.message)
        # end
      end

      subcommand 'orgs', 'Orgs ', Elasticfeed::CLI::Command::Organisations
      subcommand 'apps', 'Apps', Elasticfeed::CLI::Command::Applications
      subcommand 'feeds', 'Feeds', Elasticfeed::CLI::Command::Feeds

    end

  end

end
