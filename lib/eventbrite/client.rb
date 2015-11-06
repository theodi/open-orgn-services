require 'faraday'
require 'faraday_middleware'

module Eventbrite

  class OAuth2 < Faraday::Middleware

    def initialize(app, options)
      super(app)
      @token = options[:token]
    end

    def call(env)
      env[:request_headers]['Authorization'] = "Bearer #{@token}"
      @app.call(env)
    end
  end

  Faraday::Request.register_middleware :oauth2 => lambda { OAuth2 }

  module_function
  def connection
    @connection ||= Faraday.new(:url => "https://www.eventbriteapi.com/v3") do |conn|
      conn.request :oauth2, :token => ENV['EVENTBRITE_API_TOKEN']
      conn.response :json, :content_type => /\bjson$/
      conn.adapter Faraday.default_adapter
    end
  end

end
