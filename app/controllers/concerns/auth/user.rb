# frozen_string_literal: true

module Auth
  module User
    include Auth::Base
    extend ActiveSupport::Concern

    ACCESS_COOKIE_KEY = :"__Secure-access_user_token"
    REFRESH_COOKIE_KEY = :"__Secure-refresh_user_token"

    included do
      helper_method :current_user, :logged_in?, :active_user? if respond_to?(:helper_method)
    end

    alias_method :current_user, :current_resource

    alias_method :authenticate_user!, :authenticate!

    def audit_user_login_failed(user)
      record_audit(AUDIT_EVENTS[:login_failed], resource: user, actor: nil) if user
    end

    # Authorization methods
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
      # TODO: Implement owner check logic for user
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
      ::UserAudit
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
      new_sign_app_in_url(rt: return_to, host: ENV["SIGN_SERVICE_URL"])
    end
  end
end
