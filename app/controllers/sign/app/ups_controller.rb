# frozen_string_literal: true

module Sign
  module App
    class UpsController < ApplicationController
      guest_only! status: :unauthorized
      include Sign::App::SignUpGuard

      prevent_logged_in_signup! only: %i[new]

      def new
        session[:social_intent] = "signup"
      end
    end
  end
end
