module Gurney
  module Source
    class Yarn < Base

     YARN_LOCK_REGEX = /^"?(?<name>\S*)@.+?"?:\n\s{2}version "(?<version>.+?)"$/m

     def initialize(yarn_lock:)
       @yarn_lock = yarn_lock
     end

     def present?
       !@yarn_lock.nil?
     end

     def dependencies
       if present?
         dependencies = @yarn_lock.scan(YARN_LOCK_REGEX).map{|match| { name: match[0], version: match[1] } }
         dependencies.map { |dependency| Dependency.new(ecosystem: 'npm', **dependency) }
       end
     end

     private

     attr_reader :yarn_lock

    end
  end
end
