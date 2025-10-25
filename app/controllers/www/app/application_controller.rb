# frozen_string_literal: true

module Www
  module App
    class ApplicationController < ActionController::Base
      include Pundit::Authorization
      allow_browser versions: :modern

      protected

      def logged_in_user?
        false
      end
    end
  end
end
