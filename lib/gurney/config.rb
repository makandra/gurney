require 'yaml'

module Gurney
  class Config

    attr_accessor :branches, :api_url, :api_token, :project_id

    def initialize(branches:, api_url:, api_token:, project_id:)
      @branches = branches
      @api_url = api_url
      @api_token = api_token.to_s
      @project_id = project_id.to_s
    end

    def self.from_file(filename)
      config = YAML.load_file(filename).map{|(k,v)| [k.to_sym,v]}.to_h
      new(**config)
    end

  end
end
