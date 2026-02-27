# typed: false
# frozen_string_literal: true

module Sign
  module App
    class ConfigurationsController < ApplicationController
      auth_required!
      before_action :authenticate_user!

      def show
      end

      def edit
        return if current_user.deactivated?

        redirect_to sign_app_configuration_path(ri: params[:ri])
      end
    end
  end
end
