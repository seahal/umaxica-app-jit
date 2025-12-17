# frozen_string_literal: true

module Authentication
  module User
    include Authentication::Base
    extend ActiveSupport::Concern

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
      if Rails.env.test? && respond_to?(:request) && request && (test_user_id = request.headers["X-TEST-CURRENT-USER"])
        @current_user = ::User.find_by(id: test_user_id)
        return @current_user
      end

      # Extract token from Authorization header (Bearer) or Cookie
      access_token = extract_access_token(:access_user_token)
      return nil if access_token.blank?

      begin
        payload = verify_access_token(access_token)
        return nil unless payload["type"] == "user"

        @current_user = ::User.find_by(id: payload["sub"])
        # Treat withdrawn accounts as unauthenticated
        @current_user = nil if @current_user&.respond_to?(:withdrawn?) && @current_user.withdrawn?
      rescue JWT::ExpiredSignature, JWT::VerificationError, ActiveRecord::RecordNotFound
        @current_user = nil
      end

      @current_user
    end

    AUDIT_EVENTS = {
      logged_in: "LOGGED_IN",
      logged_out: "LOGGED_OUT",
      login_failed: "LOGIN_FAILED"
    }.freeze

    def log_in(user, record_login_audit: true)
      reset_session

      token = UserToken.create!(user_id: user.id)
      credentials = generate_access_token(user)

      # For non-JSON requests (browser), set cookies
      unless request.format.json?
        # ACCESS_TOKEN: Short-lived JWT (15 minutes)
        cookies[:access_user_token] = cookie_options.merge(
          value: credentials,
          expires: ACCESS_TOKEN_EXPIRY.from_now
        )
        # REFRESH_TOKEN: Long-lived (1 year)
        cookies.encrypted[:refresh_user_token] = cookie_options.merge(
          value: token.id,
          expires: 1.year.from_now
        )
      end

      record_user_identity_audit(AUDIT_EVENTS[:logged_in], user: user) if record_login_audit

      # Return tokens for JSON API clients
      {
        access_token: credentials,
        refresh_token: token.id,
        token_type: "Bearer",
        expires_in: ACCESS_TOKEN_EXPIRY.to_i
      }
    end

    def log_out
      user = current_user
      if (token_id = cookies.encrypted[:refresh_user_token])
        begin
          UserToken.find_by(id: token_id)&.destroy
        rescue ActiveRecord::RecordNotDestroyed => e
          Rails.logger.warn("Failed to destroy refresh token #{token_id}: #{e.message}")
        end
      end
      cookies.delete :access_user_token, **cookie_deletion_options
      cookies.delete :refresh_user_token, **cookie_deletion_options
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
        redirect_to new_sign_app_authentication_url(rt: rt, host: ENV["SIGN_SERVICE_URL"]), allow_other_host: true, alert: I18n.t("errors.messages.login_required")
      end
    end

    # Add private helper methods here
    def audit_user_login_failed(user)
      record_user_identity_audit(AUDIT_EVENTS[:login_failed], user: user, actor: nil) if user
    end

    private

    def record_user_identity_audit(event_id, user:, actor: user)
      return unless user && event_id

      ::UserIdentityAudit.create!(
        user: user,
        actor: actor,
        event_id: event_id,
        ip_address: request_ip_address,
        timestamp: Time.current
      )
    end

    def request_ip_address
      respond_to?(:request, true) && request ? request.remote_ip : nil
    end
  end
end
