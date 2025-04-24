module Www
  module App
    module Preference
      class CookiesController < ApplicationController
        def edit
          @accept_tracking_cookies = cookies.signed[:accept_tracking_cookies]
        end

        def update
          cookies.permanent.signed[:accept_tracking_cookies] = params[:accept_tracking_cookies] == '0' ? false : true
          redirect_to edit_www_app_preference_cookie_url
        end
      end

      private
      def post_params
        params.require(:post).permit(:title, :summary, :description, :url)
      end
    end
  end
end
