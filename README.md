sinatra_auth_github
===================

A sinatra extension that provides oauth authentication to github.  Find out more about enabling your application at github's [oauth quickstart](http://gist.github.com/419219).

To test it out on localhost set your callback url to 'http://localhost:9393/auth/github/callback'

The gist of this project is to provide a few things easily:

* authenticate a user against github's oauth service
* provide an easy way to make API requests for the authenticated user
* optionally restrict users to a specific github organization
* optionally restrict users to a specific github team

Installation
============

    % gem install sinatra_auth_bootic

Running the Example
===================
    % gem install bundler
    % bundle install
    % OAUTH_CLIENT_ID="<from Bootic>" OAUTH_CLIENT_SECRET="<from Bootic>" BOOTIC_API_URL=http://api.bootic.info bundle exec rackup -p9292

There's an example app in [spec/app.rb](/ismasan/sinatra_auth_bootic/blob/master/spec/app.rb).

Example App Functionality
=========================

You can simply authenticate via Bootic by hitting http://localhost:9292

API Requests
============

The extension also provides a simple way to do get requests against the
Bootic API as the authenticated user.

    def products
      bootic_request("products")
    end

Extension Options
=================

* `:scopes`       - The OAuth2 scopes you require
* `:secret`       - The client secret that GitHub provides
* `:client_id`    - The client id that GitHub provides
* `:failure_app`  - A Sinatra::Base class that has a route for `/unauthenticated`, Useful for overriding the default page.
* `:callback_url` - The path that Bootic posts back to, defaults to `/auth/bootic/callback`.
