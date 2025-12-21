# frozen_string_literal: true

module Authentication
  module Staff
    include Authentication::Base
    extend ActiveSupport::Concern

    included do
      helper_method :current_staff, :logged_in? if respond_to?(:helper_method)
    end

    class_methods do
      # Add any class methods here
    end

    AUDIT_EVENTS = {
      logged_in: "LOGGED_IN",
      logged_out: "LOGGED_OUT",
      login_failed: "LOGIN_FAILED"
    }.freeze

    def current_staff
      return @current_staff if defined?(@current_staff)

      # Test helpers can inject current staff via request header
      # This bypasses the withdrawn check to allow testing withdrawn states
      if Rails.env.test? && respond_to?(:request) && request && (test_staff_id = request.headers["X-TEST-CURRENT-STAFF"])
        @current_staff = ::Staff.find_by(id: test_staff_id)
        @bypass_withdrawn_check = true
        return @current_staff
      end

      # Extract token from Authorization header (Bearer) or Cookie
      access_token = extract_access_token(:access_staff_token)
      return nil if access_token.blank?

      begin
        payload = verify_access_token(access_token)
        return nil unless payload["type"] == "staff"

        @current_staff = ::Staff.find_by(id: payload["sub"])
        # Treat withdrawn accounts as unauthenticated (unless bypassed for testing)
        @current_staff = nil if @current_staff&.respond_to?(:withdrawn?) && @current_staff.withdrawn? && !@bypass_withdrawn_check
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

      token = TokensRecord.connected_to(role: :writing) do
        StaffToken.create!(staff_id: staff.id)
      end
      credentials = generate_access_token(staff)

      # For non-JSON requests (browser), set cookies
      unless request.format.json?
        # ACCESS_TOKEN: Short-lived JWT (15 minutes)
        cookies[:access_staff_token] = cookie_options.merge(
          value: credentials,
          expires: ACCESS_TOKEN_EXPIRY.from_now
        )
        # REFRESH_TOKEN: Long-lived (1 year)
        cookies.encrypted[:refresh_staff_token] = cookie_options.merge(
          value: token.id,
          expires: 1.year.from_now
        )
      end

      record_staff_identity_audit(AUDIT_EVENTS[:logged_in], staff: staff)

      # Return tokens for JSON API clients
      {
        access_token: credentials,
        refresh_token: token.id,
        token_type: "Bearer",
        expires_in: Authentication::Base::ACCESS_TOKEN_EXPIRY.to_i
      }
    end

    def refresh_access_token(refresh_token_id)
      # Find and validate the old refresh token
      old_token = StaffToken.find_by(id: refresh_token_id)

      unless old_token
        Rails.event.notify("staff.token.refresh.failed",
                           refresh_token_id: refresh_token_id,
                           reason: "token_not_found",
                           ip_address: request_ip_address)
        return nil
      end

      staff = old_token.staff

      unless staff&.active?
        Rails.event.notify("staff.token.refresh.failed",
                           staff_id: staff&.id,
                           refresh_token_id: refresh_token_id,
                           reason: "staff_inactive",
                           ip_address: request_ip_address)
        TokensRecord.connected_to(role: :writing) { old_token.destroy }
        return nil
      end

      # Create new refresh token (rotation)
      new_refresh_token = TokensRecord.connected_to(role: :writing) do
        StaffToken.create!(staff_id: staff.id)
      end

      # Generate new access token
      new_access_token = generate_access_token(staff)

      # Revoke old refresh token
      TokensRecord.connected_to(role: :writing) { old_token.destroy }

      Rails.event.notify("staff.token.refreshed",
                         staff_id: staff.id,
                         old_refresh_token_id: old_token.id,
                         new_refresh_token_id: new_refresh_token.id,
                         ip_address: request_ip_address)

      # Return new tokens
      {
        access_token: new_access_token,
        refresh_token: new_refresh_token.id,
        token_type: "Bearer",
        expires_in: Authentication::Base::ACCESS_TOKEN_EXPIRY.to_i
      }
    rescue StandardError => e
      Rails.event.notify("staff.token.refresh.error",
                         staff_id: staff&.id,
                         refresh_token_id: refresh_token_id,
                         error_class: e.class.name,
                         error_message: e.message,
                         ip_address: request_ip_address)
      nil
    end

    def log_out
      staff = current_staff
      if (token_id = cookies.encrypted[:refresh_staff_token])
        begin
          StaffToken.find_by(id: token_id)&.destroy
        rescue ActiveRecord::RecordNotDestroyed => e
          Rails.event.notify("staff.token.destroy.failed",
                             token_id: token_id,
                             error_message: e.message,
                             ip_address: request_ip_address)
        end
      end
      cookies.delete :access_staff_token, **cookie_deletion_options
      cookies.delete :refresh_staff_token, **cookie_deletion_options
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
        redirect_to new_auth_org_authentication_url(rt: rt, host: ENV["AUTH_STAFF_URL"]), allow_other_host: true,
                                                                                          alert: I18n.t("errors.messages.login_required")
      end
    end

    private

      def record_staff_identity_audit(event_id, staff:, actor: staff)
        return unless staff && event_id

        ::StaffIdentityAudit.create!(
          staff: staff,
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
