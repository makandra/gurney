require 'httparty'

module Gurney
  class Api

    attr_reader :base_url

    def initialize(base_url:, token:)
      @base_url = base_url
      @token = token
    end

    def post_dependencies(dependencies:, branch:, project_id:)
      data = {
          dependencies: dependencies
      }
      url = base_url
      url.gsub! '<project_id>', project_id
      url.gsub! '<branch>', branch
      post_json(url, data.to_json)
    end

    private

    attr_reader :base_url, :token

    def post_json(url, json)
      response = HTTParty.post(url,
        body: json,
        headers: { 'X-AuthToken' => @token,
          'Content-Type': 'application/json'},
      )
      unless response.success?
        raise ApiError.new("#{response.code} #{response.body}")
      end
    end

  end

  class ApiError < Exception
  end
end
