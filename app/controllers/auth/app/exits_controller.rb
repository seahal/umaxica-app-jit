# frozen_string_literal: true

module Auth
  module App
    class ExitsController < ApplicationController
      before_action :verify_session_user

      def edit
      end

      def destroy
        session.delete(:user)
        redirect_to auth_app_root_path, notice: t(".destroy.success")
      end

      private

      def verify_session_user
        raise ActionController::RoutingError, "Not Found" if session[:user].blank?
      end
    end
  end
end
