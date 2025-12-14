module Sign
  module Org
    class ExitsController < ApplicationController
      before_action :verify_session_staff

      def edit
      end

      def destroy
        session.delete(:staff)
        redirect_to sign_org_root_path, notice: t(".destroy.success")
      end

      private

      def verify_session_staff
        # puts "DEBUG: session[:staff] = #{session[:staff].inspect}"
        raise ActionController::RoutingError, "Not Found" if session[:staff].blank?
      end
    end
  end
end
