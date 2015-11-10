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

  module Client
    module_function
    def connection
      @connection ||= Faraday.new(:url => "https://www.eventbriteapi.com/v3") do |conn|
        conn.request :oauth2, :token => ENV['EVENTBRITE_API_TOKEN']
        conn.response :json, :content_type => /\bjson$/
        conn.adapter Faraday.default_adapter
      end
    end

    def paged_results(key, url, options={})
      page = 1
      loop do
        response = connection.get(url, options.merge('page' => page)).body
        response[key].each do |item|
          yield item
        end
        if page < response['pagination']['page_count']
          page += 1
        else
          break
        end
      end
    end

    def orders_since(time)
      paged_results("orders", "users/me/owned_event_orders/",
        "changed_since" => time.utc.iso8601).each do |order|
        yield order
      end
    end

    def order_details(uri)
      connection.get(uri,
        'expand' => 'event,event.ticket_classes,attendees').body
    end
  end
end
