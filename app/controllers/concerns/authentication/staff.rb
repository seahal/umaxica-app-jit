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
      if Rails.env.test? && respond_to?(:request) && request && (test_staff_id = request.headers["X-TEST-CURRENT-STAFF"])
        @current_staff = ::Staff.find_by(id: test_staff_id)
        return @current_staff
      end

      return nil if cookies[:access_staff_token].blank?

      begin
        payload = verify_access_token(cookies[:access_staff_token])
        return nil unless payload["type"] == "staff"

        @current_staff = ::Staff.find_by(id: payload["sub"])
        # Treat withdrawn accounts as unauthenticated
        @current_staff = nil if @current_staff&.respond_to?(:withdrawn?) && @current_staff.withdrawn?
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

      token = StaffToken.create!(staff_id: staff.id)
      credentials = generate_access_token(staff)

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

      record_staff_identity_audit(AUDIT_EVENTS[:logged_in], staff: staff)
    end

    def log_out
      staff = current_staff
      if cookies.encrypted[:refresh_staff_token].present?
        StaffToken.find_by(id: cookies.encrypted[:refresh_staff_token])&.destroy
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
        redirect_to new_sign_org_authentication_url(rt: rt, host: ENV["SIGN_STAFF_URL"]), allow_other_host: true, alert: I18n.t("errors.messages.login_required")
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
