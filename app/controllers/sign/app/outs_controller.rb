# frozen_string_literal: true

module Sign
  module App
    class OutsController < ApplicationController
      auth_required!
      before_action :authenticate!

      def edit
      end

      def destroy
        log_out
        redirect_to sign_app_root_path, notice: t(".success")
      end
    end
  end
end
