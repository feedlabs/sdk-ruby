module Elasticfeed
  require 'rubygems'  # For ruby < 1.9

  require "uri"
  require "json"
  require "cgi"
  require "net/http"
  require 'net/http/digest_auth'
  require 'terminal-table'
  require 'pathname'

  require 'elasticfeed/config'
  require 'elasticfeed/agent'
  require 'elasticfeed/client'
  require 'elasticfeed/cache'
  require 'elasticfeed/version'
  require 'elasticfeed/resource'
  require 'elasticfeed/errors'

  require 'elasticfeed/resource/organisation'
  require 'elasticfeed/resource/application'
  require 'elasticfeed/resource/feed'
  require 'elasticfeed/resource/entry'

  require 'elasticfeed/cli'
end
