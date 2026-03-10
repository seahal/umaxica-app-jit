# typed: false
# frozen_string_literal: true

module Apex
  module Org
    class ApplicationController < ActionController::Base
      include ::RateLimit
      include ::Preference::Global
      include ::Authentication::Staff
      include ::Authorization::Staff
      include ::Verification::Staff
      include Pundit::Authorization
      include ::Current
      include ::Finisher

      before_action :set_preferences_cookie
      before_action :resolve_param_context
      before_action :set_region
      before_action :set_locale
      before_action :set_timezone
      before_action :set_color_theme
      before_action :enforce_access_policy!
      before_action :enforce_verification_if_required
      append_after_action :finish_request

      protect_from_forgery with: :exception

      allow_browser versions: :modern

      auth_required!
    end
  end
end
