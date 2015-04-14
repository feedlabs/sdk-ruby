module Elasticfeed

  class Config

    default = {
        username: proc {
          nil
        },
        apikey: proc {
          nil
        },
        apiurl: proc {
          [api_protocol, '://', api_host, ':', api_port, api_path, '/', api_version].join.to_s
        },
        limit: proc {
          10
        },
        api_protocol: proc {
          'http'
        },
        api_host: proc {
          '127.0.0.1'
        },
        api_port: proc {
          '10100'
        },
        api_path: proc {
          ''
        },
        api_version: proc {
          'v1'
        },
        default_org_id: proc {
          nil
        },
        default_app_id: proc {
          nil
        },
        default_feed_id: proc {
          nil
        },
        config_path: proc {
          Dir.home + '/.elasticfeed-cli'
        }
    }

    default.each do |key, value|
      define_method(key) do
        if default[key].equal?(value)
          default[key] = instance_eval(&value)
        end
        default[key]
      end
      define_method("#{key}=") do |value|
        default[key] = value
      end
    end

  end
end
