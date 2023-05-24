require 'bundler'

Bundler.ui.level = 'error'

module Gurney
  module Source
    class Bundler < Base

    def initialize(gemfile_lock:)
      @gemfile_lock = gemfile_lock
    end

    def present?
      !@gemfile_lock.nil?
    end

    def dependencies
      if present?
        Dir.mktmpdir do |dir|
          Dir.chdir dir do
            File.write('Gemfile', '') # LockfileParser requires a Gemfile to be present, can be empty
            lockfile = ::Bundler::LockfileParser.new(@gemfile_lock)
            lockfile.specs.map { |spec| Dependency.new(ecosystem: 'rubygems', name: spec.name, version: spec.version.to_s) }
          end
        end
      end
    end

    private

    attr_reader :gemfile_lock

    end
  end
end
