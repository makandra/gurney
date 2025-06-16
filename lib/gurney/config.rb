require 'yaml'

module Gurney
  class Config

    attr_accessor :branches, :api_url, :api_token, :project_id, :prefix

    def initialize(branches: nil, api_url: nil, api_token: nil, project_id: nil, prefix: '.')
      @branches = branches
      @api_url = api_url
      @api_token = api_token&.to_s
      @project_id = project_id&.to_s
      @prefix = prefix&.to_s
    end

    def self.from_yaml(yaml)
        config = YAML.load(yaml)&.map{|(k,v)| [k.to_sym,v]}.to_h
        new(**config)
    end

  end
end
