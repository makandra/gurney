module Gurney
  class Dependency

    attr_reader :ecosystem, :name, :version

    def initialize(ecosystem:, name:, version:)
      @ecosystem = ecosystem
      @name = name
      @version = version
    end

    def to_json(*args)
      {
        ecosystem: @ecosystem,
        name: @name,
        version: @version,
      }.to_json(*args)
    end

  end
end
