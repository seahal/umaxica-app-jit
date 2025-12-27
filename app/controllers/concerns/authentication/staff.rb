# frozen_string_literal: true

# NOTE: If this code is only included in Staff controllers, consider moving to
# app/controllers/concerns/authentication/staff.rb

module Authentication
  module Staff
    include Authentication::Base
    extend ActiveSupport::Concern

    ACCESS_COOKIE_KEY = :"__Secure-access_staff_token"
    REFRESH_COOKIE_KEY = :"__Secure-refresh_staff_token"

    included do
      helper_method :current_staff, :logged_in? if respond_to?(:helper_method)
    end

    class_methods do
      # Add any class methods here
    end

    AUDIT_EVENTS = {
      logged_in: "LOGGED_IN",
      logged_out: "LOGGED_OUT",
      login_failed: "LOGIN_FAILED",
    }.freeze

    def current_staff
      return @current_staff if defined?(@current_staff)

      # Test helpers can inject current staff via request header
      # This bypasses the withdrawn check to allow testing withdrawn states
      if Rails.env.test? && respond_to?(:request) && request
        test_staff_id = request.headers["X-TEST-CURRENT-STAFF"]
        if test_staff_id
          @current_staff = ::Staff.find_by(id: test_staff_id)
          @bypass_withdrawn_check = true
          return @current_staff
        end
      end

      # Extract token from Authorization header (Bearer) or Cookie
      access_token = extract_access_token(ACCESS_COOKIE_KEY)
      return nil if access_token.blank?

      begin
        payload = verify_access_token(access_token)
        return nil unless payload["type"] == "staff"

        @current_staff = ::Staff.find_by(id: payload["sub"])
        # Treat withdrawn accounts as unauthenticated (unless bypassed for testing)
        if @current_staff&.respond_to?(:withdrawn?) &&
            @current_staff.withdrawn? &&
            !@bypass_withdrawn_check
          @current_staff = nil
        end
      rescue JWT::ExpiredSignature, JWT::VerificationError, ActiveRecord::RecordNotFound
        @current_staff = nil
      end

      @current_staff
    end

    def logged_in?
      current_staff.present?
    end

    def log_in(staff)
      reset_session

      token =
        TokensRecord.connected_to(role: :writing) do
          StaffToken.create!(staff_id: staff.id)
        end
      refresh_token = token.rotate_refresh_token!
      credentials = generate_access_token(staff, session_public_id: token.public_id)

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

      record_staff_identity_audit(AUDIT_EVENTS[:logged_in], staff: staff)

      # Return tokens for JSON API clients
      {
        access_token: credentials,
        refresh_token: refresh_token,
        token_type: "Bearer",
        expires_in: Authentication::Base::ACCESS_TOKEN_EXPIRY.to_i,
      }
    end

    def refresh_access_token(refresh_token)
      result = Auth::RefreshTokenService.call(refresh_token: refresh_token)
      old_token = result[:token]

      unless old_token.is_a?(StaffToken)
        Rails.event.notify(
          "staff.token.refresh.failed",
          refresh_token_id: refresh_token,
          reason: "token_not_found",
          ip_address: request_ip_address,
        )
        return nil
      end

      staff = old_token.staff

      unless staff&.active?
        Rails.event.notify(
          "staff.token.refresh.failed",
          staff_id: staff&.id,
          refresh_token_id: refresh_token,
          reason: "staff_inactive",
          ip_address: request_ip_address,
        )
        TokensRecord.connected_to(role: :writing) { old_token.destroy! }
        return nil
      end

      # Generate new access token
      new_access_token = generate_access_token(staff, session_public_id: old_token.public_id)

      Rails.event.notify(
        "staff.token.refreshed",
        staff_id: staff.id,
        old_refresh_token_id: old_token.public_id,
        new_refresh_token_id: result[:refresh_token],
        ip_address: request_ip_address,
      )

      # Return new tokens
      {
        access_token: new_access_token,
        refresh_token: result[:refresh_token],
        token_type: "Bearer",
        expires_in: Authentication::Base::ACCESS_TOKEN_EXPIRY.to_i,
      }
    rescue Auth::InvalidRefreshToken => e
      Rails.event.notify(
        "staff.token.refresh.failed",
        refresh_token_id: refresh_token,
        reason: e.class.name,
        ip_address: request_ip_address,
      )
      nil
    rescue StandardError => e
      Rails.event.notify(
        "staff.token.refresh.error",
        staff_id: staff&.id,
        refresh_token_id: refresh_token,
        error_class: e.class.name,
        error_message: e.message,
        ip_address: request_ip_address,
      )
      nil
    end

    def log_out
      staff = current_staff
      token_value = cookies.encrypted[REFRESH_COOKIE_KEY]
      if token_value
        begin
          public_id, = StaffToken.parse_refresh_token(token_value)
          StaffToken.find_by(public_id: public_id)&.destroy if public_id
        rescue ActiveRecord::RecordNotDestroyed => e
          Rails.event.notify(
            "staff.token.destroy.failed",
            token_id: token_value,
            error_message: e.message,
            ip_address: request_ip_address,
          )
        end
      end
      cookies.delete ACCESS_COOKIE_KEY, **cookie_deletion_options
      cookies.delete REFRESH_COOKIE_KEY, **cookie_deletion_options
      record_staff_identity_audit(AUDIT_EVENTS[:logged_out], staff: staff) if staff
      reset_session
      @current_staff = nil
    end

    def authenticate_staff!
      return if logged_in?

      if request.format.json?
        render json: { error: "Unauthorized" }, status: :unauthorized
      else
        rt = Base64.urlsafe_encode64(request.original_url)
        redirect_to(
          new_auth_org_authentication_url(rt: rt, host: ENV["AUTH_STAFF_URL"]),
          allow_other_host: true,
          alert: I18n.t("errors.messages.login_required"),
        )
      end
    end

    private

    def record_staff_identity_audit(event_id, staff:, actor: staff)
      return unless staff && event_id

      audit = ::StaffIdentityAudit.new(
        actor: actor,
        event_id: event_id,
        ip_address: request_ip_address,
        occurred_at: Time.current,
      )
      audit.staff = staff
      audit.save!
    end

    def request_ip_address
      (respond_to?(:request, true) && request) ? request.remote_ip : nil
    end
  end
end
