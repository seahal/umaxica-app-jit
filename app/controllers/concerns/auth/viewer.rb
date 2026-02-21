# frozen_string_literal: true

module Auth
  module Viewer
    extend ActiveSupport::Concern
    include Auth::Base

    # Cookie keys are defined in Auth::Base (environment-dependent)
    ACCESS_COOKIE_KEY = Auth::Base::ACCESS_COOKIE_KEY
    REFRESH_COOKIE_KEY = Auth::Base::REFRESH_COOKIE_KEY
    AUDIT_EVENTS = Auth::Base::AUDIT_EVENTS

    included do
      helper_method :current_viewer, :logged_in?, :active_viewer?, :logged_in_viewer? if respond_to?(:helper_method)
      alias_method :current_viewer, :current_resource
      alias_method :authenticate_viewer!, :authenticate!
      alias_method :logged_in_viewer?, :logged_in?
    end

    def audit_viewer_login_failed(viewer)
      # No-op for viewer since they cannot log in
    end

    # Authorization methods
    def active_viewer?
      false
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

    # Since Viewer is strictly for public endpoints, we override the default refresh behavior.
    # We do not want to randomly crash if a stale token cookie is passed.
    def transparent_refresh_access_token
      nil
    end

    def authenticate!
      if request.format.json?
        render json: { error: "Unauthorized" }, status: :unauthorized
      else
        # rubocop:disable Rails/I18nLocaleTexts
        redirect_to "/", alert: "権限がありません"
        # rubocop:enable Rails/I18nLocaleTexts
      end
    end

    private

    def resource_class
      ::Object
    end

    def token_class
      ::Object
    end

    def audit_class
      ::Object
    end

    def resource_type
      "viewer"
    end

    def resource_foreign_key
      :viewer_id
    end

    def test_header_key
      "X-TEST-CURRENT-VIEWER"
    end

    def sign_in_url_with_return(_return_to)
      "/"
    end
  end
end
