#!/usr/bin/env ruby
# @TODO(joe): re-serialize files into a proper gem structure. create gemspec + gem
# @TODO(joe): implement way more of the sensu api

require 'rubygems'
require 'json'
require 'thor'
require 'thor/group'
require 'highline'
require 'rest-client'

# @TODO(joe): move sensuApi class into SensuCli module
# helpers for accessing the REST interface of the sensu api
class SensuApi

  def initialize(api_url)
    @api_url = api_url
    @connection = RestClient::Resource.new(@api_url)
  end

  def request(url, method='GET', data='', content_type='application/json')
    case method
    when 'GET'
      @connection[url].get
    when 'POST'
      @connection[url].post data, :content_type => content_type
    end

  end

  def status_to_string(status)
    case status
    when 0  then 'OK'
    when 1  then 'WARNING'
    when 2  then 'CRITICAL'
    when 3  then 'UNKNOWN'
    end
  end

end

  # https://github.com/sensu/sensu/wiki/Sensu%20API
module SensuCli

  # Exceptions
  class NotYetImplementedException < Exception; end

  # /info
  class Info < Thor
    namespace :info
    default_task :info

    desc "info", "returns the API info"
    def info
      raise NotYetImplementedException
    end
  end

  # /clients
  class Clients < Thor
    namespace :clients
  end

  # /stashes
  class Stashes < Thor
    namespace :stashes
  end

  # /events
  class Events < Thor
    namespace :events
    default_task :list

    option :all,
      :desc => 'display all events, including UNKNOWN',
      :aliases => '-a',
      :type => :boolean
    desc "list", "list active WARNING or CRITICAL events"
    def list
      api = SensuApi.new(parent_options.sensu_api_url)
      events = JSON.parse(api.request('/events'))
       events.each do |event|
        unless options.all
          next unless event['status'] == 1 or event['status'] == 2
        end
        severity = api.status_to_string(event['status'])

        severity_color = case severity
          when 'WARNING' then :yellow
          when 'CRITICAL' then :red
          else :green
        end
        say "#{severity} #{event['client']} #{event['check']}", severity_color
        say "Output:  #{event['output']}\n"
      end
    end
  end

  # /checks
  class Checks < Thor
    namespace :checks
    default_task :list

    desc "list", "list registered checks"
    def list
      api = SensuApi.new(parent_options.sensu_api_url)
      checks = JSON.parse(api.request('/checks'))
      checks.each do |check|
        puts check
      end
    end

    desc "request <check_name> <subscribers>", "trigger an execution of check_name on subscribers"
    def request(check, subscribers)
      api = SensuApi.new(parent_options.sensu_api_url)
      request = {'check' => check, 'subscribers' => subscribers.split(',')}
      result = api.request('/check/request', method = 'POST', data = JSON.dump(request))
      puts result
    end
  end

  # main CLI generator
  class CLI < Thor
    desc "events <command>", '/events API access'
    subcommand 'events', Events

    desc "checks <command>", '/checks API access'
    subcommand 'checks', Checks

    desc 'info', '/info API access'
    subcommand 'info', Info

    desc 'clients <command>', '/clients and /client API access'
    subcommand 'clients', Clients

    desc 'stashes <command>', '/stashes API access'
    subcommand 'stashes', Stashes

    # global options, availabe via `parent_option.option_name` in Task classes
    class_option :sensu_api_url,
      :desc => "URL of Sensu API (or set environment var SENSU_API_URL)",
      :type => :string,
      :default => ENV['SENSU_API_URL'] || 'http://localhost:4567',
      :required => true

    # @TODO(joe): global class_option for '--output=format'. text, json, etc
  end

end

if __FILE__ == $0
  SensuCli::CLI.start
end
