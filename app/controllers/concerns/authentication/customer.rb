# typed: false
# frozen_string_literal: true

module Authentication
  module Customer
    extend ActiveSupport::Concern

    include Authentication::Base

    ACCESS_COOKIE_KEY = Authentication::Base::ACCESS_COOKIE_KEY
    REFRESH_COOKIE_KEY = Authentication::Base::REFRESH_COOKIE_KEY
    DEVICE_COOKIE_KEY = Authentication::Base::DEVICE_COOKIE_KEY
    ACCESS_TOKEN_TTL = Authentication::Base::ACCESS_TOKEN_TTL
    REFRESH_TOKEN_TTL = Authentication::Base::REFRESH_TOKEN_TTL
    AUDIT_EVENTS = Authentication::Base::AUDIT_EVENTS

    included do
      helper_method :current_customer, :logged_in?, :active_customer?,
                    :logged_in_customer? if respond_to?(:helper_method)
      alias_method :current_customer, :current_resource
      alias_method :authenticate_customer!, :authenticate!
      alias_method :logged_in_customer?, :logged_in?
      include ::AuthorizationAudit
    end

    def audit_customer_login_failed(customer)
      record_audit(AUDIT_EVENTS[:login_failed], resource: customer, actor: nil) if customer
    end

    def active_customer?
      current_customer.present? && current_customer.active?
    end

    def am_i_user?
      false
    end

    def am_i_staff?
      false
    end

    def am_i_owner?
      false
    end

    private

    def resource_class
      ::User
    end

    def token_class
      UserToken
    end

    def audit_class
      ::UserActivity
    end

    # Compatibility shim: sign/com still authenticates against user-backed
    # sessions until dedicated customer token/session models land.
    def resource_type
      "user"
    end

    def resource_foreign_key
      :user_id
    end

    def max_sessions_for_resource(resource)
      return 1 if resource.is_a?(::User)

      super
    end

    # FIXME: what is this method?
    def test_header_key
      "X-TEST-CURRENT-USER"
    end

    def sign_in_url_with_return(return_to)
      new_sign_com_in_url(
        rt: return_to,
        host: ENV.fetch("SIGN_CORPORATE_URL", "sign.com.localhost"),
        protocol: request.protocol,
      )
    end
  end
end
