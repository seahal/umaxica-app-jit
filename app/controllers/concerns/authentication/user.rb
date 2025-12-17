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
      Rails.logger.debug { "DEBUG: current_user called. @current_user defined? #{defined?(@current_user)}" }
      Rails.logger.debug caller[0..5]
      return @current_user if defined?(@current_user)

      # Test helpers can inject a current user via request header to support
      # controller instance dispatch in tests. Only allow this in the test
      # environment to avoid an authentication backdoor in production.
      if Rails.env.test? && respond_to?(:request) && request && (test_user_id = request.headers["X-TEST-CURRENT-USER"])
        @current_user = ::User.find_by(id: test_user_id)
        return @current_user
      end

      return nil if cookies[:access_user_token].blank?

      begin
        payload = verify_access_token(cookies[:access_user_token])
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

      # ACCESS_TOKEN: Short-lived JWT (15 minutes)
      cookies[:access_user_token] = {
        value: credentials,
        httponly: true,
        secure: Rails.env.production?,
        samesite: :lax,
        expires: ACCESS_TOKEN_EXPIRY.from_now
      }
      # REFRESH_TOKEN: Long-lived (1 year)
      cookies.encrypted[:refresh_user_token] = {
        value: token.id,
        httponly: true,
        secure: Rails.env.production?,
        samesite: :lax,
        expires: 1.year.from_now
      }

      record_user_identity_audit(AUDIT_EVENTS[:logged_in], user: user) if record_login_audit
    end

    def log_out
      user = current_user
      if cookies.encrypted[:refresh_user_token].present?
        UserToken.find_by(id: cookies.encrypted[:refresh_user_token])&.destroy
      end
      cookies.delete :access_user_token
      cookies.delete :refresh_user_token
      record_user_identity_audit(AUDIT_EVENTS[:logged_out], user: user) if user
      reset_session
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
