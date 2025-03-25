module Gurney
  class DependencyCollector

    def initialize(git_file_reader)
      @git_file_reader = git_file_reader
    end

    def collect_all
      dependencies = []

      dependencies.concat npm_dependencies
      dependencies.concat bundler_dependencies
      dependencies.concat ruby_version_dependencies

      dependencies.compact
    end

    private

    def bundler_dependencies
      bundler_source = Gurney::Source::Bundler.new(gemfile_lock: @git_file_reader.read('Gemfile.lock'))
      bundler_source.dependencies || []
    end

    def ruby_version_dependencies
      ruby_version_source = Gurney::Source::RubyVersion.new(ruby_version: @git_file_reader.read('.ruby-version'))
      ruby_version_source.dependencies || []
    end

    def npm_dependencies
      npm_dependencies = []

      if yarn_lock
        yarn_source = Gurney::Source::Yarn.new(yarn_lock: yarn_lock)
        npm_dependencies.concat(yarn_source.dependencies || [])
      end

      if package_lock_json
        npm_source = Gurney::Source::Npm.new(package_lock_json: package_lock_json)
        npm_dependencies.concat(npm_source.dependencies || [])
      end

      if pnpm_lock
        pnpm_source = Gurney::Source::Pnpm.new(pnpm_lock: pnpm_lock)
        npm_dependencies.concat(pnpm_source.dependencies || [])
      end

      npm_dependencies
    end

    def yarn_lock
      @yarn_lock ||= @git_file_reader.read('yarn.lock')
    end

    def package_lock_json
      @package_lock_json = @git_file_reader.read('package-lock.json')
    end

    def pnpm_lock
      @pnpm_lock = @git_file_reader.read('pnpm-lock.yaml')
    end

  end
end
