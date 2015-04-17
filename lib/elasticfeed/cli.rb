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

      option ['-o', '--default-org-id'], '<string>', 'Default Elasticfeed organisation id' do |o|
        @config.default_org_id = o
      end

      option ['-p', '--default-app-id'], '<string>', 'Default Elasticfeed application id' do |p|
        @config.default_app_id = p
      end

      option ['-f', '--default-feed-id'], '<string>', 'Default Elasticfeed feed id' do |f|
        @config.default_feed_id = f
      end

      option ['--cfg'], '<string>', 'Config file path' do |p|
        @config.config_path = p
        parse_user_home_config
      end

      option ['-i', '--ignore'], :flag, 'Ignore flag of --default-xxx-id', :default => false

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

      def feeds
        id = ignore? ? nil : @config.default_feed_id

        applications.collect! { |application|
          id.nil? ? application.feeds : application.feed(id)
        }.flatten
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

      subcommand 'list', 'Application list' do

        def execute
          print(Elasticfeed::Resource::Application.table_header, applications)
        end
      end

    end

    class Elasticfeed::CLI::Command::Feeds < Elasticfeed::CLI::Command

      subcommand 'list', 'Feed list' do

        def execute
          print(Elasticfeed::Resource::Feed.table_header, feeds)
        end
      end

      subcommand 'empty', 'Clear all entries from UI' do
        def execute
          feeds.each do |feed|
            feed.empty
          end
        end
      end

      subcommand 'reload', 'Reload all active UI' do
        def execute
          feeds.each do |feed|
            feed.reload
          end
        end
      end

      subcommand 'new-entry', 'New feed entry' do

        parameter '[data]', 'Data as <string>', :default => ''

        def execute
          feeds.each do |feed|
            feed.new_entry(data)
          end
        end
      end

      subcommand 'new-workflow', 'New feed workflow' do

        parameter '[data]', 'Data as <string>', :default => ''

        def execute
          feeds.each do |feed|
            feed.new_workflow(data)
          end
        end
      end

    end

    class Elasticfeed::CLI::Command::Entries < Elasticfeed::CLI::Command

      subcommand 'list', 'Entry list' do

        def execute
          entry_list = feeds.collect! { |feed| feed.entries }.flatten
          print(Elasticfeed::Resource::Entry.table_header, entry_list)
        end
      end

      subcommand 'delete', 'Entry list' do

        parameter '[id]', 'Entry Id'

        def execute
          entry_list = feeds.collect! { |feed| feed.entries }.flatten
          entry = entry_list.select! {| entry| entry.id == id }.first
          if entry.nil?
            puts "Cannot load entry id `#{id}` "
          else
            entry.delete
            puts "Remove of entry id `#{id}` has finished successfully"
          end
        end
      end

    end

    class Elasticfeed::CLI::Command::Workflows < Elasticfeed::CLI::Command

      subcommand 'list', 'Workflow list' do

        def execute
          workflow_list = feeds.collect! { |feed| feed.workflows }.flatten
          print(Elasticfeed::Resource::Workflow.table_header, workflow_list)
        end
      end

    end

    class Elasticfeed::CLI::CommandManager < Elasticfeed::CLI::Command

      def run(arguments)
        begin
          super
        rescue Exception => e
          abort(e.message.empty? ? 'Unknown error/Interrupt' : e.message)
        end
      end

      subcommand 'org', 'Orgs ', Elasticfeed::CLI::Command::Organisations
      subcommand 'app', 'Apps', Elasticfeed::CLI::Command::Applications
      subcommand 'feed', 'Feeds', Elasticfeed::CLI::Command::Feeds
      subcommand 'entry', 'Entries', Elasticfeed::CLI::Command::Entries
      subcommand 'workflow', 'Workflows', Elasticfeed::CLI::Command::Workflows

    end

  end

end
