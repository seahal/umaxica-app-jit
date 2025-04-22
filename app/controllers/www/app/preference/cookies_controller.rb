module Www
  module App
    module Preference
      class CookiesController < ApplicationController
        def edit
        end

        def update
          redirect_to '/'
        end
      end
    end
  end
end
