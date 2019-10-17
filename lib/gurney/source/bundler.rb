require 'bundler'

module Gurney
  module Source
    class Bundler < Base

    def initialize(filename: 'Gemfile.lock')
      @filename = filename
    end

    def present?
      File.exists? filename
    end

    def dependencies
      if present?
        lockfile = ::Bundler::LockfileParser.new(::Bundler.read_file(filename))
        lockfile.specs.map { |spec| Dependency.new(ecosystem: 'rubygems', name: spec.name, version: spec.version.to_s) }
      end
    end

    private

    attr_reader :filename

    end
  end
end
