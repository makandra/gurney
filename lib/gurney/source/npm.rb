require 'json'
require 'colorize'

module Gurney
  module Source
    class Npm < Base

      SUPPORTED_LOCKFILE_VERSIONS = [2, 3].freeze
     
      def initialize(package_lock_json:)
        @package_lock_json = package_lock_json
      end

      def present?
        !@package_lock_json&.empty?
      end

      def dependencies
        if present?
          parsed_lock = JSON.parse(@package_lock_json)

          if SUPPORTED_LOCKFILE_VERSIONS.include?(parsed_lock['lockfileVersion'])
            extract_dependencies(parsed_lock)
          else
            puts "package-lock.json: Lockfile version #{parsed_lock['lockfileVersion']} is unsupported. No npm dependencies reported.".yellow
            []
          end
        end
      rescue JSON::ParserError => e
        raise Gurney::Error.new("Invalid package-lock.json format: #{e.message}")
      end

      private

      attr_reader :package_lock_json

      def extract_dependencies(parsed_lock)
        dependencies = []

        if parsed_lock['packages']
          parsed_lock['packages'].each do |path_to_package, details|
            next if path_to_package == ''

            name = path_to_package.sub(/^node_modules\//, '') # remove "node_modules/" prefix to get package name
            dependencies << Dependency.new(
              ecosystem: 'npm',
              name: name,
              version: details['version']
            )
          end
        end

        dependencies
      end

    end
  end
end
