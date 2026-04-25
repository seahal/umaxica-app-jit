# typed: false
# frozen_string_literal: true

module Jit
  module Identity
    module Sign
      module EdgeV0JsonApi
        extend ActiveSupport::Concern

        class_methods do
          def activate_edge_v0_json_api
            before_action :ensure_json_request
            skip_before_action :set_region
          end
        end

        private

        def authenticate!
          return if logged_in?

          render json: { error: "Unauthorized" }, status: :unauthorized
        end

        def ensure_json_request
          request.format = :json
        end
      end
    end
  end
end
