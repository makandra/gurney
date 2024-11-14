require 'optparse'
require 'securerandom'
require 'colorize'
require 'open3'
require 'git'
require 'fileutils'

module Gurney
  class CLI
    HOOK_STDIN_REGEX = /(?<old>[0-9a-f]{40}) (?<new>[0-9a-f]{40}) refs\/heads\/(?<ref>\w+)/m
    CLIENT_HOOK_STDIN_REGEX = /refs\/heads\/(?<ref>\w+) (?<new>[0-9a-f]{40}) refs\/heads\/(?<remote_ref>\w+) (?<remote_sha>[0-9a-f]{40})/m
    MAIN_BRANCHES = ['master', 'main'].freeze

    def self.run(cmd_parameter=[])
      options = Gurney::CLI::OptionParser.parse(cmd_parameter)

      begin
        if options.hook
          g = Git.bare(ENV['GIT_DIR'] || Dir.pwd)
        else
          unless Dir.exist? './.git'
            raise Gurney::Error.new('Must be run within a git repository')
          end
          g = Git.open('.')
        end
        config_file = MAIN_BRANCHES.find do |branch|
          file = read_file(g, options.hook, branch, options.config_file)
          break file if file
        end
        if !config_file && options.hook
          # dont run as a hook with no config
          exit 0
        end
        config_file ||= '---'
        config = Gurney::Config.from_yaml(config_file)

        options.branches ||= config&.branches
        options.branches ||= config&.branches
        options.api_token ||= config&.api_token
        options.api_url ||= config&.api_url
        options.project_id ||= config&.project_id

        if [options.project_id, options.branches, options.api_url, options.api_token].any?(&:nil?)
          raise Gurney::Error.new("Either provide in a config file or set the flags for project id, branches, api url and api token")
        end

        branches = []
        if options.hook || options.client_hook
          # we get passed changed branches and refs via stdin
          $stdin.each_line do |line|
            regex = options.client_hook ? CLIENT_HOOK_STDIN_REGEX : HOOK_STDIN_REGEX
            line.force_encoding(Encoding::UTF_8)
            matches = line.match(regex)
            if matches && matches[:new] != '0' * 40
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

          yarn_source = Gurney::Source::Yarn.new(yarn_lock: read_file(g, options.hook || options.client_hook, branch, 'yarn.lock'))
          dependencies.concat yarn_source.dependencies || []

          bundler_source = Gurney::Source::Bundler.new(gemfile_lock: read_file(g, options.hook || options.client_hook, branch, 'Gemfile.lock'))
          dependencies.concat bundler_source.dependencies || []

          ruby_version_source = Gurney::Source::RubyVersion.new(ruby_version: read_file(g, options.hook || options.client_hook, branch, '.ruby-version'))
          dependencies.concat ruby_version_source.dependencies || []

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
        raise
      end
    end

    private

    def self.read_file(git, from_git, branch, filename)
      if from_git
        begin
          git.show("#{branch}:#{filename}")
        rescue Git::GitExecuteError
          # happens if branch does not exist
        end
      else
        if File.exist? filename
          return File.read filename
        end
      end
    end

  end

  class Error < Exception
  end
end
