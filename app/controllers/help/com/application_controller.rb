# typed: false
# frozen_string_literal: true

module Help
  module Com
    class ApplicationController < ActionController::Base
      include ::Fuse
      include ::RateLimit
      include ::Preference::Regional
      include ::Authentication::Viewer
      include ::Authorization::Viewer
      include ::Verification::Viewer
      include Pundit::Authorization
      include ::Current
      include ::Finisher

      before_action :check_fuse!
      before_action :enforce_access_policy!
      before_action :enforce_verification_if_required
      before_action :set_current
      append_after_action :finish_request

      protect_from_forgery with: :exception

      allow_browser versions: :modern

      public_strict!
    end
  end
end
