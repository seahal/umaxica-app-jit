# typed: false
# frozen_string_literal: true

module Authentication
  module Staff
    extend ActiveSupport::Concern

    include Authentication::Base

    ACCESS_COOKIE_KEY = Authentication::Base::ACCESS_COOKIE_KEY
    REFRESH_COOKIE_KEY = Authentication::Base::REFRESH_COOKIE_KEY
    DEVICE_COOKIE_KEY = Authentication::Base::DEVICE_COOKIE_KEY
    ACCESS_TOKEN_TTL = Authentication::Base::ACCESS_TOKEN_TTL
    REFRESH_TOKEN_TTL = Authentication::Base::REFRESH_TOKEN_TTL
    AUDIT_EVENTS = Authentication::Base::AUDIT_EVENTS

    class_methods do
      def activate_staff_authentication
        activate_authentication_base

        helper_method :current_staff, :logged_in?, :active_staff?,
                      :logged_in_staff? if respond_to?(:helper_method)
        alias_method(:current_staff, :current_resource)
        alias_method(:authenticate_staff!, :authenticate!)
        alias_method(:logged_in_staff?, :logged_in?)
        include ::AuthorizationAudit

        activate_authorization_audit
      end
    end

    def audit_staff_login_failed(staff)
      record_audit(AUDIT_EVENTS[:login_failed], resource: staff, actor: nil) if staff
    end

    def active_staff?
      current_staff.present? && current_staff.active?
    end

    def am_i_user?
      false
    end

    def am_i_staff?
      true
    end

    def am_i_owner?
      false
    end

    private

    def resource_class
      ::Staff
    end

    def token_class
      StaffToken
    end

    def audit_class
      ::StaffActivity
    end

    def resource_type
      "staff"
    end

    def resource_foreign_key
      :staff_id
    end

    # Header key for test environment staff injection.
    # Allows tests to set the current staff via request headers.
    def test_header_key
      "X-TEST-CURRENT-STAFF"
    end

    def sign_in_url_with_return(return_to)
      new_sign_org_in_url(
        rt: return_to,
        host: ENV.fetch("SIGN_STAFF_URL", "sign.org.localhost"),
        protocol: request.protocol,
      )
    end
  end
end
