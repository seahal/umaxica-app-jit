# typed: false
# frozen_string_literal: true

module Jit
  module Identity
    module Sign
      module Com
        class ConfigurationsController < ApplicationController
          auth_required!
          before_action :authenticate_customer!

          def show
          end

          def edit
            return if current_customer.deactivated?

            safe_redirect_to(
              identity.sign_com_configuration_path(ri: params[:ri]),
              fallback: identity.sign_com_configuration_path,
            )
          end
        end
      end
    end
  end
end
