require 'optparse'
require 'securerandom'
require 'colorize'
require 'open3'

module Gurney
  class CLI

    HOOK_STDIN_REGEX = /(?<old>[0-9a-f]{40}) (?<new>[0-9a-f]{40}) refs\/heads\/(?<ref>\w+)/m

    def self.run
      options = Gurney::CLI::OptionParser.parse(ARGV)

      begin
        if options.hook
          # when run as hook we need to clone the bare repository
          tmp_dir = options.tmp_dir
          work_dir = tmp_dir + '/work_dir_' + SecureRandom.hex(8)
          Dir.mkdir tmp_dir
          Dir.mkdir work_dir

          # clone to tmp dir
          output, status = Open3.capture2e("git clone $GIT_DIR #{work_dir}")
          unless status.success?
            raise "git clone failed\n#{output}"
          end
          Dir.chdir(work_dir)
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
            puts "No config file found.\n".red +
                 "Either provide a config file or set the flags for project id, api url and api token".red
            exit -1
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
          work_dir = '.'
          current_branch, _= Open3.capture3("git rev-parse --abbrev-ref HEAD")
          current_branch.gsub!("\n", '')
          unless config.branches.nil? || config.branches.include?(current_branch)
            raise 'The current branch is not specified in the config.'
          end
          branches << current_branch
        end

        branches.each do |branch|
          if options[:hook]
            output, status = Open3.capture2e("git --git-dir=#{work_dir + '/.git'} --work-tree=#{work_dir} checkout #{branch}")
            unless status.success?
              raise "git checkout failed\n#{output}"
            end
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
      rescue Exception => e
        puts "error:".red
        puts "#{e.full_message}"
      ensure
        `rm -Rf #{tmp_dir}`
      end
    end
  end
end
