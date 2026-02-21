# frozen_string_literal: true

module Authentication
  module Viewer
    extend ActiveSupport::Concern

    include Authentication::Base

    included do
      helper_method :current_viewer, :logged_in?, :active_viewer?, :logged_in_viewer? if respond_to?(:helper_method)
      alias_method :current_viewer, :current_resource
      alias_method :authenticate_viewer!, :authenticate!
      alias_method :logged_in_viewer?, :logged_in?
    end

    def audit_viewer_login_failed(_viewer)
      nil
    end

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

    # Viewer is public-only: ignore stale auth cookies.
    def transparent_refresh_access_token
      nil
    end

    def authenticate!
      if request.format.json?
        render json: { error: "Unauthorized" }, status: :unauthorized
      else
        redirect_to "/", alert: I18n.t("auth.unauthorized")
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
