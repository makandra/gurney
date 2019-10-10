#!/usr/bin/env ruby

require 'open3'
require 'net/http'
require 'json'
require 'optparse'

# config
TMP_DIR = '/tmp/dep_reporter'
API_BASE_URI = 'http://172.17.0.1:3000/'


STDIN_REGEX = /(?<old>[0-9a-f]{40}) (?<new>[0-9a-f]{40}) refs\/heads\/(?<ref>\w+)/m
YARN_LOCK_REGEX = /^"?(?<name>\S*)@.+?"?:\n\s{2}version "(?<version>.+?)"$/m
GEMFILE_LOCK_REGEX = /^ {4}(?<name>\w+) \((?<version>.+?)\)/m

# parse command line options
options = {
  local: false
}
OptionParser.new do |opts|
  opts.banner = 'Usage: dep_reporter.rb [options]'

  opts.on('-l', '--local', 'run locally within a project folder') do
    options[:local] = true
  end
  opts.on('', '--project-name <project name>', 'specify the gitlab project name when running locally') do |projectname|
    options[:projectname] = projectname
  end
end.parse!

if options[:local] && !options.has_key?(:projectname)
  raise OptionParser::MissingArgument.new('If run locally you must specify a project name')
end

work_dir = options[:local] ? '.' : TMP_DIR + '/work_dir'

puts "\e[36mDependency Reporter\e[0m"
# puts "git_dir: #{git_dir}"
# puts "Environment:"
# ENV.each do |key, value|
#   puts "#{key}: #{value}"
# end

class String
  def red
    "\e[31m#{self}\e[0m"
  end
end

begin
  branches = []
  if options[:local]
    # when run locally we already have the source files but not the gitlab project name
    gitlab_project_name = options[:projectname]

    # if run locally use current branch
    current_branch, _= Open3.capture3("git rev-parse --abbrev-ref HEAD")
    branches << current_branch.gsub("\n", '')
  else
    # run as a a hook

    Dir.mkdir TMP_DIR

    # get gitlab namespace/projectname
    gitlab_project_name, error, status = Open3.capture3("git config --get gitlab.fullpath")
    gitlab_project_name.gsub! "\n", ''
    unless status.success?
      raise "could not get project name\n#{error}"
    end

    # if run as a hook we get passed changed branches via stdin
    $stdin.each_line do |line|
      matches = line.match(STDIN_REGEX)
      unless matches[:new] == '0' * 40
        branches << matches[:ref]
      end
    end

    # clone to tmp dir
    output, status = Open3.capture2e("git clone $GIT_DIR #{work_dir}")
    unless status.success?
      raise "git clone failed\n#{output}"
    end
    Dir.chdir(work_dir)
  end


  # checkout each branch and look for dependencies
  branches.each do |branch|
    begin
      dependency_sources = {}
      # checkout
      unless options[:local]
        output, status = Open3.capture2e("git --git-dir=#{work_dir + '/.git'} --work-tree=#{work_dir} checkout #{branch}")
        unless status.success?
          raise "git checkout failed\n#{output}"
        end
      end

      # ruby
      ruby_version = 'unknown'
      if File.exists?('.ruby-version')
        ruby_version = File.read('.ruby-version').gsub "\n", ''
      end

      # bundler
      if File.exists?('Gemfile.lock')
        gemfile_lock = File.read('Gemfile.lock')
        gemfile_lock.gsub! /^\s*remote: (.+)$/, '' # remove remote lines as they might contain creadentials
        dependencies = gemfile_lock.scan(GEMFILE_LOCK_REGEX).map{|match| { name: match[0], version: match[1] } }
        dependency_sources[:ruby_gems] = dependencies
      end

      # yarn
      if File.exists?('yarn.lock')
        yarn_lock = File.read('yarn.lock')
        dependencies = yarn_lock.scan(YARN_LOCK_REGEX).map{|match| { name: match[0], version: match[1] } }
        dependency_sources[:npm] = dependencies
      end

      # send dependencies to api
      data = {
        gitlab_project_name: gitlab_project_name,
        branch: branch,
        ruby_version: ruby_version,
        dependency_sources: dependency_sources,
      }
      #pp data
      uri = URI(API_BASE_URI + '/dep_reporter/project_branch')
      http = Net::HTTP.new(uri.host, uri.port)
      request = Net::HTTP::Post.new(uri.path, 'Content-Type' => 'application/json')
      request.body = data.to_json
      response = http.request(request)
      unless response.is_a?(Net::HTTPSuccess)
        raise "api failed\n#{response}"
      end

    rescue Exception => e
      puts "  error while processing master:".red
      puts "  #{e}".red
    end
  end

rescue Exception => e
  puts "  error:".red
  puts "  #{e}".red
ensure
  # cleanup
  unless options[:local]
    `rm -Rf #{TMP_DIR}`
  end
end
