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
        if logged_in?
          enforce_withdrawal_gate_after_auth!
          return if performed?

          return
        end

        # TODO: Consider single-flight/lock by user or refresh token to avoid
        # duplicate refresh across concurrent requests (DB/Redis/Durable Object).
        # Keep refresh attempts bounded to at most once per request.
        refresh_from_cookie_once!
        if logged_in?
          enforce_withdrawal_gate_after_auth!
          return if performed?

          return
        end

        if respond_to?(:refresh_failure_code, true) && refresh_failure_code == "withdrawal_required"
          render json: { error: "WITHDRAWAL_REQUIRED" }, status: :forbidden
          return
        end

        render json: { error: "unauthorized" }, status: :unauthorized
      end

      def refresh_from_cookie_once!
        return if request.env["jit_edge_token_refreshed"]

        refresh_plain = cookies[Auth::Base::REFRESH_COOKIE_KEY]
        return if refresh_plain.blank?

        # Cross-request single-flight: acquire a short-lived cache lock keyed on the
        # refresh token digest so concurrent requests don't all attempt to exchange
        # the same (single-use) refresh token simultaneously.
        lock_key = "edge:refresh_lock:#{Digest::SHA256.hexdigest(refresh_plain).take(16)}"
        return unless Rails.cache.write(lock_key, 1, expires_in: 15.seconds, unless_exist: true)

        request.env["jit_edge_token_refreshed"] = true
        refreshed = refresh_access_token(refresh_plain)
        @current_resource = refreshed[:user] if refreshed
      end

      def enforce_withdrawal_gate_after_auth!
        return unless respond_to?(:enforce_withdrawal_gate!, true)

        enforce_withdrawal_gate!
      end
    end
  end
end
