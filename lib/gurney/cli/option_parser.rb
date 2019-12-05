require 'optparse'
require 'ostruct'

module Gurney
  class CLI
    class OptionParser

      def self.parse(args)
        options = OpenStruct.new
        options.hook = false
        options.client_hook = false
        options.config_file = 'gurney.yml'

        option_parser = ::OptionParser.new do |opts|
          opts.banner = "Usage: gurney [options]"

          opts.on('',
                  '--api-url [API URL]',
                  "Url for web api call, can have parameters for <project_id> and <branch>" ,
                  "example: --api-url \"http://example.com/project/<project_id>/branch/<branch>\"") do |api_url|
            options.api_url = api_url
          end

          opts.on('', '--api-token [API TOKEN]', 'Token to be send to the api in the X-AuthToken header') do |api_token|
            options.api_token = api_token
          end

          opts.on('-c', '--config [CONFIG FILE]', 'Config file to use') do |config_file|
             options.config_file = config_file
           end

          opts.on('-h', '--hook', 'Run as a git post-receive hook') do |hook|
            options.hook = hook
          end

          opts.on('', '--client-hook', 'Run as a git pre-push hook') do |client_hook|
            options.client_hook = client_hook
          end

          opts.on('-p', '--project-id [PROJECT ID]', 'Specify project id for api') do |project_id|
            options.project_id = project_id
          end

          opts.on_tail('', '--help', 'Prints this help') do
            puts opts
            exit
          end
        end

        option_parser.parse!(args)
        options
      end

    end
  end
end
