# frozen_string_literal: true

module Auth
  module Staff
    extend ActiveSupport::Concern
    include Auth::Base

    # Cookie keys are defined in Auth::Base (environment-dependent)
    ACCESS_COOKIE_KEY = Auth::Base::ACCESS_COOKIE_KEY
    REFRESH_COOKIE_KEY = Auth::Base::REFRESH_COOKIE_KEY
    AUDIT_EVENTS = Auth::Base::AUDIT_EVENTS

    included do
      helper_method :current_staff, :logged_in?, :active_staff?, :logged_in_staff? if respond_to?(:helper_method)
      alias_method :current_staff, :current_resource
      alias_method :authenticate_staff!, :authenticate!
      alias_method :logged_in_staff?, :logged_in?
    end

    def audit_staff_login_failed(staff)
      record_audit(AUDIT_EVENTS[:login_failed], resource: staff, actor: nil) if staff
    end

    # Authorization methods
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
      # TODO: Implement owner check logic for staff
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
      ::StaffAudit
    end

    def resource_type
      "staff"
    end

    def resource_foreign_key
      :staff_id
    end

    def test_header_key
      "X-TEST-CURRENT-STAFF"
    end

    def sign_in_url_with_return(return_to)
      new_sign_org_in_url(
        rt: return_to,
        host: ENV["SIGN_STAFF_URL"],
        protocol: request.protocol,
      )
    end
  end
end
