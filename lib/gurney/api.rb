require 'httparty'
require 'cgi'

module Gurney
  class Api

    def initialize(base_url:, token:)
      @base_url = base_url
      @token = token
    end

    def post_dependencies(dependencies:, branch:, project_id:, repo_path: nil)
      data = { dependencies: dependencies }
      data[:repository_path] = repo_path if repo_path

      url = base_url
      url.gsub! '<project_id>', CGI.escape(project_id)
      url.gsub! '<branch>', CGI.escape(branch)

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
        if response.code == 404
          raise ApiError.new("#{response.code} API url is probably wrong")
        else
          raise ApiError.new("#{response.code} #{response.body}")
        end
      end
    end

  end

  class ApiError < Exception
  end
end
