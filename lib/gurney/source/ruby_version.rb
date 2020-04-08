require 'bundler'

module Gurney
  module Source
    class RubyVersion < Base

    def initialize(ruby_version:)
      @ruby_version = ruby_version&.strip
    end

    def present?
      @ruby_version && @ruby_version.size > 0
    end

    def dependencies
      if present?
        [Dependency.new(ecosystem: 'ruby', name: 'ruby', version: @ruby_version)]
      end
    end

    private

    attr_reader :gemfile_lock

    end
  end
end
