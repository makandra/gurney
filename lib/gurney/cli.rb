require 'optparse'
require 'securerandom'
require 'colorize'
require 'open3'
require 'git'
require 'fileutils'

module Gurney
  class CLI

    HOOK_STDIN_REGEX = /(?<old>[0-9a-f]{40}) (?<new>[0-9a-f]{40}) refs\/heads\/(?<ref>\w+)/m

    def self.run(cmd_parameter=[])
      options = Gurney::CLI::OptionParser.parse(cmd_parameter)

      begin
        if options.hook
          g = Git.bare(ENV['GIT_DIR'])
        else
          unless Dir.exists? './.git'
            raise Gurney::Error.new('Must be run within a git repository')
          end
          g = Git.open('.')
        end

        if g.ls_tree("master")['blob'].key?(options.config_file)
          config = Gurney::Config.from_yaml(g.show("master:#{options.config_file}"))

          options.branches ||= config.branches
          options.api_token ||= config.api_token
          options.api_url ||= config.api_url
          options.project_id ||= config.project_id
        else
          if options.hook
            # dont run as a hook with no config
            exit 0
          end
        end

        if [options.project_id, options.branches, options.api_url, options.api_token].any?(&:nil?)
          raise Gurney::Error.new("Either provide in a config file or set the flags for project id, branches, api url and api token")
        end

        branches = []
        if options.hook
          # we get passed changed branches and refs via stdin
          $stdin.each_line do |line|
            matches = line.match(HOOK_STDIN_REGEX)
            unless matches[:new] == '0' * 40
              if options.branches.include? matches[:ref]
                branches << matches[:ref]
              end
            end
          end

        else
          current_branch = g.current_branch
          unless options.branches.nil? || options.branches.include?(current_branch)
            raise Gurney::Error.new('The current branch is not specified in the config.')
          end
          branches << current_branch
        end

        branches.each do |branch|
          dependencies = []

          if g.ls_tree(branch)['blob'].key?('yarn.lock')
            yarn_lock = g.show("#{branch}:yarn.lock")
            yarn_source = Gurney::Source::Yarn.new(yarn_lock: yarn_lock)
            dependencies.concat yarn_source.dependencies || []
          end

          if g.ls_tree(branch)['blob'].key?('Gemfile.lock')
            gemfile_lock = g.show("#{branch}:Gemfile.lock")
            bundler_source = Gurney::Source::Bundler.new(gemfile_lock: gemfile_lock)
            dependencies.concat bundler_source.dependencies || []
          end

          dependencies.compact!

          api = Gurney::Api.new(base_url: options.api_url, token: options.api_token)
          api.post_dependencies(dependencies: dependencies, branch: branch, project_id: options.project_id)

          dependency_counts = dependencies.group_by(&:ecosystem).map{|ecosystem, dependencies| "#{ecosystem}: #{dependencies.count}" }.join(', ')
          puts "Gurney: reported dependencies (#{dependency_counts})"
        end

      rescue SystemExit
      rescue Gurney::ApiError => e
        puts "Gurney: api error".red
        puts e.message.red
      rescue Gurney::Error => e
        puts "Gurney: error".red
        puts e.message.red
      rescue Exception => e
        puts "Gurney: an unexpected error occurred".red
        puts "#{e.full_message}"
      end
    end
  end

  class Error < Exception
  end
end
