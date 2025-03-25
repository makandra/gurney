require 'yaml'
require 'colorize'

module Gurney
  module Source
    class Pnpm < Base
      def initialize(pnpm_lock:)
        @pnpm_lock = pnpm_lock
      end

      def present?
        !@pnpm_lock&.empty?
      end

      def dependencies
        if present?
          parsed_lock = YAML.safe_load(@pnpm_lock)

          major_version = parsed_lock['lockfileVersion'].split('.').first
          if major_version == '9'
            extract_dependencies(parsed_lock)
          else
            puts "pnpm-lock.yaml: Lockfile version #{major_version} is unsupported. No npm dependencies reported.".yellow
            []
          end
        end
      rescue Psych::SyntaxError => e
        raise Gurney::Error.new("Invalid pnpm-lock.yaml format: #{e.message}")
      end

      private

      attr_reader :pnpm_lock

      def extract_dependencies(parsed_lock)
        dependencies = []

        # dependency_id has format <scoped_pkg_name>@<pkg_version>
        # see https://github.com/pnpm/spec/blob/master/lockfile/9.0.md#packages
        parsed_lock['packages'].each_key do |dependency_id|
          name, _, version = dependency_id.rpartition('@')
          dependencies << Dependency.new(
            ecosystem: 'npm',
            name: name,
            version: version
          )
        end

        dependencies
      end

    end
  end
end 
