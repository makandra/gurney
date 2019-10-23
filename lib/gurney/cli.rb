require 'optparse'
require 'securerandom'
require 'colorize'
require 'open3'
require 'git'
require 'fileutils'

module Gurney
  class CLI

    HOOK_STDIN_REGEX = /(?<old>[0-9a-f]{40}) (?<new>[0-9a-f]{40}) refs\/heads\/(?<ref>\w+)/m

    def self.run
      options = Gurney::CLI::OptionParser.parse(ARGV)

      begin
        if options.hook
          tmp_dir = options.tmp_dir
          work_dir = tmp_dir + '/work_dir_' + SecureRandom.hex(8)
          Dir.mkdir tmp_dir
          Dir.mkdir work_dir

          g = Git.clone(ENV['GIT_DIR'], work_dir)
          Dir.chdir(work_dir)
        else
          work_dir = '.'
          unless Dir.exists? './.git'
            raise Gurney::Error.new('Must be run within a git repository')
          end
          g = Git.open(work_dir)
        end

        if File.exists? options.config_file
          config = Gurney::Config.from_file(options.config_file)
          config.api_token = options.api_token if options.api_token&.present?
          config.api_url = options.api_url if options.api_url&.present?
          config.project_id = options.project_id if options.project_id&.present?
        else
          if options.hook
            # dont run as a hook with no config
            exit 0
          elsif [options.project_id, options.api_url, options.api_token].any?(&:nil?)
            raise Gurney::Error.new("No config file found.\n"+
              "Either provide a config file or set the flags for project id, api url and api token")
          else
            config = Gurney::Config.new(branches: nil, **options.slice(:api_url, :api_token, :project_id))
          end
        end

        branches = []
        if options.hook
          # we get passed changed branches and refs via stdin
          $stdin.each_line do |line|
            matches = line.match(HOOK_STDIN_REGEX)
            unless matches[:new] == '0' * 40
              if config.branches.include? matches[:ref]
                branches << matches[:ref]
              end
            end
          end

        else
          current_branch = g.current_branch
          unless config.branches.nil? || config.branches.include?(current_branch)
            raise Gurney::Error.new('The current branch is not specified in the config.')
          end
          branches << current_branch
        end

        branches.each do |branch|
          if options.hook
            g.checkout branch
          end

          dependencies = []

          yarn_source = Gurney::Source::Yarn.new
          dependencies.concat yarn_source.dependencies || []

          bundler_source = Gurney::Source::Bundler.new
          dependencies.concat bundler_source.dependencies || []

          dependencies.compact!


          api = Gurney::Api.new(base_url: config.api_url, token: config.api_token)
          api.post_dependencies(dependencies: dependencies, branch: branch, project_id: config.project_id)
        end

      rescue SystemExit
      rescue Gurney::ApiError => e
        puts "api error:".red
        puts e.message.red
      rescue Gurney::Error => e
        puts "error:".red
        puts e.message.red
      rescue Exception => e
        puts "an unexpected error occurred:".red
        puts "#{e.full_message}"
      ensure
        if options.hook
         FileUtils.rm_rf tmp_dir
        end
      end
    end
  end

  class Error < Exception
  end
end
