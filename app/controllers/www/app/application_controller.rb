# frozen_string_literal: true


module Www
  module App
    class ApplicationController < ActionController::Base
      allow_browser versions: :modern

      before_action :check_authentication

      protected

      def logged_in_user?
        false
      end

      def logged_in_staff?
        false
      end

      private

      def check_authentication
        user_id = 0
        staff_id = 0

        cookies.encrypted[:access_token] = {
          value: { user_id:, staff_id: },
          httponly: true,
          secure: Rails.env.production? ? true : false,
          expires: 30.seconds.from_now
        }
        cookies.encrypted[:refresh_token] = {
          value: { user_id:, staff_id: },
          httponly: true,
          secure: Rails.env.production? ? true : false,
          expires: 1.years.from_now
        }
      end
    end
  end
end
