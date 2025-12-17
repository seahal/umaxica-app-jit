# frozen_string_literal: true

module Sign
  module Org
    module Token
      class RefreshesController < ApplicationController
        skip_forgery_protection only: :create
        before_action :validate_refresh_token, only: :create

        # POST /sign/org/token/refresh
        # Request body: { refresh_token: "uuid..." }
        # Response: { access_token: "jwt...", token_type: "Bearer", expires_in: 900 }
        def create
          staff_token = StaffToken.find_by(id: @refresh_token_id)

          if staff_token.nil?
            render json: { error: "Invalid refresh token" }, status: :unauthorized
            return
          end

          staff = Staff.find_by(id: staff_token.staff_id)

          if staff.nil? || (staff.respond_to?(:withdrawn?) && staff.withdrawn?)
            staff_token.destroy
            render json: { error: "Staff not found or withdrawn" }, status: :unauthorized
            return
          end

          # Generate new access token
          access_token = generate_access_token(staff)

          render json: {
            access_token: access_token,
            token_type: "Bearer",
            expires_in: ::Authentication::Base::ACCESS_TOKEN_EXPIRY.to_i
          }, status: :ok
        rescue StandardError => e
          Rails.logger.error "Token refresh failed: #{e.class}: #{e.message}"
          render json: { error: "Token refresh failed" }, status: :internal_server_error
        end

        private

        def validate_refresh_token
          @refresh_token_id = params[:refresh_token]

          if @refresh_token_id.blank?
            render json: { error: "refresh_token is required" }, status: :bad_request
          end
        end
      end
    end
  end
end
