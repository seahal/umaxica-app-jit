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
        last_mfa_time = nil

        cookies.encrypted[:access_token] = {
          value: { id: nil, user_id:, staff_id:, created_at: Time.now, expires_at: nil },
          httponly: true,
          secure: Rails.env.production? ? true : false,
          expires: 30.seconds.from_now
        }

        refresh_token_expires_at = 1.years.from_now
        cookies.encrypted[:refresh_token] = {
          value: { id: nil, user_id:, staff_id:, last_mfa_time:, created_at: Time.now, expires_at: refresh_token_expires_at },
          httponly: true,
          secure: Rails.env.production? ? true : false,
          expires: refresh_token_expires_at
        }
      end
    end
  end
end
