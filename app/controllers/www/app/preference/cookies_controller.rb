module Www
  module App
    module Preference
      class CookiesController < ApplicationController
        def edit
        end

        def update
          # TODO: implement!
          cookies.permanent.signed[:eprivacy] = true
          redirect_to edit_www_app_preference_cookie_url
        end
      end
    end
  end
end
