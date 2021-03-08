#!/usr/bin/ruby

require_relative './gitlab'
require 'json'
require 'httplog'

HttpLog.configure do |config|
  config.enabled = true

  config.logger = Logger.new($stderr)

  config.log_data = false
  config.log_response = false

  config.json_parser = JSON
end

timer 5 * 60
