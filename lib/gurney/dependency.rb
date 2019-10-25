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

    def ==(other)
      other.class == self.class &&
      other.ecosystem == ecosystem &&
      other.name == name &&
      other.version == version
    end

  end
end
