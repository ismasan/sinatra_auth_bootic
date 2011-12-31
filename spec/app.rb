require 'pp'

module Example
  class App < Sinatra::Base
    use Rack::Session::Cookie, :key => 'rack.session',
                               :path => '/',
                               :expire_after => 2592000, # In seconds
                               :secret => 'change_me2',
                               :old_secret => 'change_me2'

    set :bootic_options, {
                            :secret    => ENV['OAUTH_CLIENT_SECRET'],
                            :client_id => ENV['OAUTH_CLIENT_ID'],
                         }
    

    register Sinatra::Auth::Bootic
    
    disable :raise_errors
    disable :show_exceptions
    
    error RestClient::Unauthorized do
      logout!
      "Unauthorized or expired token, try <a href='/'>logging in</a> again!"
    end
    
    helpers do
      def products
        bootic_request("products")
      end
    end

    get '/' do
      authenticate!
      "Hello There, #{bootic_user.user_name}!#{bootic_user.token}\n#{products.inspect}"
    end

    get '/logout' do
      logout!
      "LOGGED OUT!"
    end
  end
end
