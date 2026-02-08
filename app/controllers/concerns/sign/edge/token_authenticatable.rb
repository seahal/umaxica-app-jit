# frozen_string_literal: true

module Sign
  module Edge
    module TokenAuthenticatable
      extend ActiveSupport::Concern

      included do
        before_action :authenticate_edge_token!
      end

      private

      def authenticate_edge_token!
        return if logged_in?

        # TODO: Consider single-flight/lock by user or refresh token to avoid
        # duplicate refresh across concurrent requests (DB/Redis/Durable Object).
        # Keep refresh attempts bounded to at most once per request.
        refresh_from_cookie_once!
        return if logged_in?

        render json: { signed_in: false, error: "unauthorized" }, status: :unauthorized
      end

      def refresh_from_cookie_once!
        return if request.env["jit_edge_signed_in_refreshed"]

        refresh_plain = cookies[Auth::Base::REFRESH_COOKIE_KEY]
        return if refresh_plain.blank?

        request.env["jit_edge_signed_in_refreshed"] = true
        refreshed = refresh_access_token(refresh_plain)
        @current_resource = refreshed[:user] if refreshed
      end
    end
  end
end
