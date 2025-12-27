# frozen_string_literal: true

# NOTE: If this code is only included in User controllers, consider moving to
# app/controllers/concerns/authentication/user.rb

module Authentication
  module User
    include Authentication::Base
    extend ActiveSupport::Concern

    ACCESS_COOKIE_KEY = :"__Secure-access_user_token"
    REFRESH_COOKIE_KEY = :"__Secure-refresh_user_token"

    included do
      helper_method :current_user, :logged_in? if respond_to?(:helper_method)
    end

    class_methods do
      # Add any class methods here
    end

    def current_user
      return @current_user if defined?(@current_user)

      # Test helpers can inject a current user via request header to support
      # controller instance dispatch in tests. Only allow this in the test
      # environment to avoid an authentication backdoor in production.
      if Rails.env.test? && respond_to?(:request) && request
        test_user_id = request.headers["X-TEST-CURRENT-USER"]
        if test_user_id
          @current_user = ::User.find_by(id: test_user_id)
          return @current_user
        end
      end

      # Extract token from Authorization header (Bearer) or Cookie
      access_token = extract_access_token(ACCESS_COOKIE_KEY)
      return nil if access_token.blank?

      begin
        payload = verify_access_token(access_token)
        return nil unless payload["type"] == "user"

        @current_user = ::User.find_by(id: payload["sub"])
        # Treat withdrawn accounts as unauthenticated
        if @current_user&.respond_to?(:withdrawn?) && @current_user.withdrawn?
          @current_user = nil
        end
      rescue JWT::ExpiredSignature, JWT::VerificationError, ActiveRecord::RecordNotFound
        @current_user = nil
      end

      @current_user
    end

    AUDIT_EVENTS = {
      logged_in: "LOGGED_IN",
      logged_out: "LOGGED_OUT",
      login_failed: "LOGIN_FAILED",
    }.freeze

    def log_in(user, record_login_audit: true)
      reset_session

      token =
        TokensRecord.connected_to(role: :writing) do
          UserToken.create!(user_id: user.id)
        end
      refresh_token = token.rotate_refresh_token!
      credentials = generate_access_token(user, session_public_id: token.public_id)

      # For non-JSON requests (browser), set cookies
      unless request.format.json?
        # ACCESS_TOKEN: Short-lived JWT (15 minutes)
        cookies[ACCESS_COOKIE_KEY] = cookie_options.merge(
          value: credentials,
          expires: ACCESS_TOKEN_EXPIRY.from_now,
        )
        # REFRESH_TOKEN: Long-lived (1 year)
        cookies.encrypted[REFRESH_COOKIE_KEY] = cookie_options.merge(
          value: refresh_token,
          expires: 1.year.from_now,
        )
      end

      record_user_identity_audit(AUDIT_EVENTS[:logged_in], user: user) if record_login_audit

      # Return tokens for JSON API clients
      {
        access_token: credentials,
        refresh_token: refresh_token,
        token_type: "Bearer",
        expires_in: ACCESS_TOKEN_EXPIRY.to_i,
      }
    end

    def refresh_access_token(refresh_token)
      result = Auth::RefreshTokenService.call(refresh_token: refresh_token)
      old_token = result[:token]

      unless old_token.is_a?(UserToken)
        Rails.event.notify(
          "user.token.refresh.failed",
          refresh_token_id: refresh_token,
          reason: "token_not_found",
          ip_address: request_ip_address,
        )
        return nil
      end

      user = old_token.user

      unless user&.active?
        Rails.event.notify(
          "user.token.refresh.failed",
          user_id: user&.id,
          refresh_token_id: refresh_token,
          reason: "user_inactive",
          ip_address: request_ip_address,
        )
        TokensRecord.connected_to(role: :writing) { old_token.destroy! }
        return nil
      end

      # Generate new access token
      new_access_token = generate_access_token(user, session_public_id: old_token.public_id)

      Rails.event.notify(
        "user.token.refreshed",
        user_id: user.id,
        old_refresh_token_id: old_token.public_id,
        new_refresh_token_id: result[:refresh_token],
        ip_address: request_ip_address,
      )

      # Return new tokens
      {
        access_token: new_access_token,
        refresh_token: result[:refresh_token],
        token_type: "Bearer",
        expires_in: ACCESS_TOKEN_EXPIRY.to_i,
      }
    rescue Auth::InvalidRefreshToken => e
      Rails.event.notify(
        "user.token.refresh.failed",
        refresh_token_id: refresh_token,
        reason: e.class.name,
        ip_address: request_ip_address,
      )
      nil
    rescue StandardError => e
      Rails.event.notify(
        "user.token.refresh.error",
        user_id: user&.id,
        refresh_token_id: refresh_token,
        error_class: e.class.name,
        error_message: e.message,
        ip_address: request_ip_address,
      )
      nil
    end

    def log_out
      user = current_user
      token_value = cookies.encrypted[REFRESH_COOKIE_KEY]
      if token_value
        begin
          public_id, = UserToken.parse_refresh_token(token_value)
          UserToken.find_by(public_id: public_id)&.destroy if public_id
        rescue ActiveRecord::RecordNotDestroyed => e
          Rails.event.notify(
            "user.token.destroy.failed",
            token_id: token_value,
            error_message: e.message,
            ip_address: request_ip_address,
          )
        end
      end
      cookies.delete ACCESS_COOKIE_KEY, **cookie_deletion_options
      cookies.delete REFRESH_COOKIE_KEY, **cookie_deletion_options
      record_user_identity_audit(AUDIT_EVENTS[:logged_out], user: user) if user
      reset_session
      @current_user = nil
    end

    def logged_in?
      current_user.present?
    end

    def authenticate_user!
      return if logged_in?

      if request.format.json?
        render json: { error: "Unauthorized" }, status: :unauthorized
      else
        rt = Base64.urlsafe_encode64(request.original_url)
        redirect_to(
          new_auth_app_authentication_url(rt: rt, host: ENV["AUTH_SERVICE_URL"]),
          allow_other_host: true,
          alert: I18n.t("errors.messages.login_required"),
        )
      end
    end

    # Add private helper methods here
    def audit_user_login_failed(user)
      record_user_identity_audit(AUDIT_EVENTS[:login_failed], user: user, actor: nil) if user
    end

    private

    def record_user_identity_audit(event_id, user:, actor: user)
      return unless user && event_id

      audit = ::UserIdentityAudit.new(
        actor: actor,
        event_id: event_id,
        ip_address: request_ip_address,
        occurred_at: Time.current,
      )
      audit.user = user
      audit.save!
    end

    def request_ip_address
      (respond_to?(:request, true) && request) ? request.remote_ip : nil
    end
  end
end
