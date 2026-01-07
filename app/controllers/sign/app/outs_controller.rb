# frozen_string_literal: true

module Sign
  module App
    class OutsController < ApplicationController
      include Sign::SessionVerification

      before_action :verify_session_user

      def edit
      end

      def destroy
        session.delete(:user)
        redirect_to sign_app_root_path, notice: t(".destroy.success")
      end
    end
  end
end
