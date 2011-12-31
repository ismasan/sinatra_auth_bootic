require 'sinatra/base'
require 'warden-bootic'
require 'rest_client'

module Sinatra
  module Auth
    module Bootic
      VERSION = "0.1.5"
      API_URL = ENV['BOOTIC_API_URL'] || 'https://api.bootic.net'
      
      # Simple way to serve an image early in the stack and not get blocked by
      # application level before filters
      class AccessDenied < Sinatra::Base
        enable :raise_errors
        disable :show_exceptions

        get '/_images/logo-bootic.png' do
          send_file(File.join(File.dirname(__FILE__), "views", "logo-bootic.png"))
        end
      end

      # The default failure application, this is overridable from the extension config
      class BadAuthentication < Sinatra::Base
        enable :raise_errors
        disable :show_exceptions

        helpers do
          def unauthorized_template
            @unauthenticated_template ||= File.read(File.join(File.dirname(__FILE__), "views", "401.html"))
          end
        end

        get '/unauthenticated' do
          status 403
          unauthorized_template
        end
      end

      module Helpers
        def warden
          env['warden']
        end

        def authenticate!(*args)
          warden.authenticate!(*args)
        end

        def authenticated?(*args)
          warden.authenticated?(*args)
        end

        def logout!
          warden.logout
        end

        # The authenticated user object
        #
        # Supports a variety of methods, name, full_name, email, etc
        def bootic_user
          warden.user
        end

        # Send a V1 API GET request to path
        #
        # path - the path on api.bootic.net to hit
        #
        # Returns a rest client response object
        #
        # Examples
        #   bootic_raw_request("/products")
        #   # => RestClient::Response
        def bootic_raw_request(path)
          RestClient.get("#{API_URL}/#{path}", :params => { :access_token => bootic_user.token }, :accept => :json)
        end

        # Send a V3 API GET request to path and JSON parse the response body
        #
        # path - the path on api.bootic.net to hit
        #
        # Returns a parsed JSON response
        #
        # Examples
        #   bootic_request("/oauth/me")
        #   # => { 'login' => 'atmos', ... }
        def bootic_request(path)
          JSON.parse(bootic_raw_request(path))
        end

        def _relative_url_for(path)
          request.script_name + path
        end
      end

      def self.registered(app)
        app.use AccessDenied
        app.use Warden::Manager do |manager|
          manager.default_strategies :bootic

          manager.failure_app           = app.bootic_options[:failure_app] || BadAuthentication

          manager[:secret]       = app.bootic_options[:secret]       || ENV['OAUTH_CLIENT_SECRET']
          manager[:scopes]       = app.bootic_options[:scopes]       || ''
          manager[:client_id]    = app.bootic_options[:client_id]    || ENV['OAUTH_CLIENT_ID']
          manager[:callback_url] = app.bootic_options[:callback_url] || '/auth/bootic/callback'
        end

        app.helpers Helpers

        app.get '/auth/bootic/callback' do
          authenticate!
          return_to = session.delete('return_to') || _relative_url_for('/')
          redirect return_to
        end
      end
    end
  end
end
