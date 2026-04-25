# typed: false
# frozen_string_literal: true

module Jit
  module Identity
    module Sign
      module App
        class ConfigurationsController < ApplicationController
          auth_required!
          before_action :authenticate_user!

          def show
          end

          def edit
            return if current_user.deactivated?

            safe_redirect_to(
              identity.sign_app_configuration_path(ri: params[:ri]),
              fallback: identity.sign_app_configuration_path,
            )
          end
        end
      end
    end
  end
end
