# typed: false
# frozen_string_literal: true

module Apex
  module Com
    class ApplicationController < ActionController::Base
      include ::Fuse
      include ::RateLimit
      include ::Preference::Global
      include ::Authentication::User
      include ::Authorization::User
      include ::Verification::User
      include Pundit::Authorization
      include ::Current
      include ::Finisher

      before_action :check_fuse!
      before_action :set_preferences_cookie
      before_action :resolve_param_context
      before_action :set_region
      before_action :set_locale
      before_action :set_timezone
      before_action :set_color_theme
      before_action :enforce_withdrawal_gate!
      before_action :transparent_refresh_access_token, unless: -> { request.format.json? }
      before_action :enforce_access_policy!
      before_action :enforce_verification_if_required
      append_after_action :finish_request

      protect_from_forgery with: :exception

      allow_browser versions: :modern

      public_strict!
    end
  end
end
