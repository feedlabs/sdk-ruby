module Elasticfeed

  class Client

    attr_accessor :username
    attr_accessor :apikey
    attr_accessor :url

    # @param [String] username
    # @param [String] apikey
    # @param [String] url
    def initialize(username = nil, apikey = nil, url = nil)
      @username = username
      @apikey = apikey
      @url = url.nil? ? 'https://localhost:10100/v1' : url
    end

    # @param [String] path
    # @return [Hash]
    def get(path)
      _request(Net::HTTP::Get, @url + path, @username, @apikey, nil)
    end

    # @param [String] path
    # @param [Hash] data
    # @return [Hash]
    def post(path, data)
      _request(Net::HTTP::Post, @url + path, @username, @apikey, data)
    end

    # @param [String] path
    # @param [Hash] data
    # @return [Hash]
    def put(path, data, binary = false)
      _request(Net::HTTP::Put, @url + path, @username, @apikey, data, binary)
    end

    # @param [String] path
    # @return [Hash]
    def delete(path)
      _request(Net::HTTP::Delete, @url + path, @username, @apikey)
    end

    private

    # @param [Net::HTTPRequest] http_method
    # @param [String] path
    # @param [String] username
    # @param [String] password
    # @param [Hash] data
    # @return [Hash]
    def _request(http_method, path, username, password, data = nil, binary = false)

      content_type = binary == false ? 'application/json' : 'application/octet-stream'

      digest_auth = Net::HTTP::DigestAuth.new
      digest_auth.next_nonce

      uri = URI.parse path
      uri.user= CGI.escape(username)
      uri.password= CGI.escape(password)

      http = Net::HTTP.new uri.host, uri.port
      http.use_ssl = (uri.scheme == 'https')

      req = http_method.new(uri.request_uri, {'Content-Type' => content_type})
      res = http.request req

      raise 'Invalid method' unless http_method.kind_of? Class and http_method < Net::HTTPRequest
      req = http_method.new(uri.request_uri, {'Content-Type' => content_type})
      method_name = http_method.name.split('::').last.upcase
      auth = digest_auth.auth_header(uri, res['WWW-Authenticate'], method_name)
      req.add_field 'Authorization', auth
      req.body = binary == false ? data.to_json : data

      response = http.request req

      response_json = JSON.parse response.body

      unless response.code == '200' or response_json['error'].nil?
        msg = "http 'get' error for url `#{url}`"
        msg = response_json['detail'] unless response_json['detail'].nil?

        raise Elasticfeed::AuthError.new(msg, req, response) if response.code == '401'
        raise Elasticfeed::ApiError.new(msg, req, response)
      end

      response_json
    end

  end
end
