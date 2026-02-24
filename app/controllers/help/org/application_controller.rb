# typed: false
# frozen_string_literal: true

module Help
  module Org
    class ApplicationController < ActionController::Base
      include ::Fuse
      include ::RateLimit
      include ::Preference::Regional
      include ::Authentication::Staff
      include ::Authorization::Staff
      include ::Verification::Staff
      include Pundit::Authorization
      include ::Finisher

      before_action :check_fuse!
      before_action :enforce_access_policy!
      before_action :enforce_verification_if_required
      append_after_action :finish_request

      protect_from_forgery with: :exception

      allow_browser versions: :modern

      public_strict!
    end
  end
end
