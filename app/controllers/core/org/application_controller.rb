# typed: false
# frozen_string_literal: true

module Core
  module Org
    class ApplicationController < ActionController::Base
      include ::Fuse
      include ::RateLimit
      include ::Authentication::Staff
      include ::Authorization::Staff
      include ::Verification::Staff
      include ::Preference::Regional
      include Pundit::Authorization
      include ::Current
      include ::Finisher

      before_action :check_fuse!
      before_action :enforce_access_policy!
      before_action :enforce_verification_if_required
      skip_before_action :set_preferences_cookie, raise: false
      skip_before_action :canonicalize_regional_params, raise: false
      skip_before_action :set_locale, raise: false
      skip_before_action :set_timezone, raise: false
      skip_before_action :set_color_theme, raise: false
      before_action :set_preferences_cookie
      before_action :canonicalize_regional_params
      before_action :set_locale
      before_action :set_timezone
      before_action :set_color_theme
      before_action :set_current
      append_after_action :finish_request

      protect_from_forgery with: :exception

      allow_browser versions: :modern

      public_strict!
    end
  end
end
