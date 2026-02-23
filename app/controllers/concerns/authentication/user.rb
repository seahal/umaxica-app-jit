# typed: false
# frozen_string_literal: true

module Authentication
  module User
    extend ActiveSupport::Concern

    include Authentication::Base

    ACCESS_COOKIE_KEY = Auth::Base::ACCESS_COOKIE_KEY
    REFRESH_COOKIE_KEY = Auth::Base::REFRESH_COOKIE_KEY
    DEVICE_COOKIE_KEY = Auth::Base::DEVICE_COOKIE_KEY
    ACCESS_TOKEN_TTL = Auth::Base::ACCESS_TOKEN_TTL
    REFRESH_TOKEN_TTL = Auth::Base::REFRESH_TOKEN_TTL
    AUDIT_EVENTS = Auth::Base::AUDIT_EVENTS

    included do
      helper_method :current_user, :logged_in?, :active_user?, :logged_in_user? if respond_to?(:helper_method)
      alias_method :current_user, :current_resource
      alias_method :authenticate_user!, :authenticate!
      alias_method :logged_in_user?, :logged_in?
      before_action :enforce_withdrawal_gate! if respond_to?(:before_action)
      before_action :transparent_refresh_access_token, unless: -> {
        request.format.json?
      } if respond_to?(:before_action)
      include ::AuthorizationAudit
    end

    def audit_user_login_failed(user)
      record_audit(AUDIT_EVENTS[:login_failed], resource: user, actor: nil) if user
    end

    def active_user?
      current_user.present? && current_user.active?
    end

    def am_i_user?
      true
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

    def resource_type
      "user"
    end

    def resource_foreign_key
      :user_id
    end

    def test_header_key
      "X-TEST-CURRENT-USER"
    end

    def sign_in_url_with_return(return_to)
      new_sign_app_in_url(
        rt: return_to,
        host: ENV.fetch("SIGN_SERVICE_URL", "sign.app.localhost"),
        protocol: request.protocol,
      )
    end
  end
end
