module Gurney
  module Source
    class Yarn < Base

     YARN_LOCK_REGEX = /^"?(?<name>\S*)@.+?"?:\n\s{2}version "(?<version>.+?)"$/m

     def initialize(filename: 'yarn.lock')
       @filename = filename
     end

     def present?
       File.exists? filename
     end

     def dependencies
       if present?
         yarn_lock = File.read(filename)
         dependencies = yarn_lock.scan(YARN_LOCK_REGEX).map{|match| { name: match[0], version: match[1] } }
         dependencies.map { |dependency| Dependency.new(ecosystem: 'npm', **dependency) }
       end
     end

     private

     attr_reader :filename

    end
  end
end
