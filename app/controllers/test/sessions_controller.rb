module Test
  class SessionsController < ApplicationController
    before_action :ensure_test_environment

    def create_staff
      session[:staff] = params[:id]
      head :ok
    end

    private

    def ensure_test_environment
      raise ActionController::RoutingError, "Not Found" unless Rails.env.test?
    end
  end
end
