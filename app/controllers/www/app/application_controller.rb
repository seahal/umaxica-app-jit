# frozen_string_literal: true

module Www
  module App
    class ApplicationController < ActionController::Base
      allow_browser versions: :modern

      before_action :check_session

      private

      def check_session
        cookies[:sample] = {
          value: "sample",
          httponly: true,
          secure: true,
          expires: 1.years
        }
        cookies["abc"] = "abc"
      end
    end
  end
end
