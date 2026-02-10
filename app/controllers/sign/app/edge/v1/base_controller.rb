# frozen_string_literal: true

module Sign
  module App
    module Edge
      module V1
        class BaseController < Sign::App::ApplicationController
          public_strict!
          before_action :ensure_json_request
          skip_before_action :set_region
          skip_forgery_protection

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
end
