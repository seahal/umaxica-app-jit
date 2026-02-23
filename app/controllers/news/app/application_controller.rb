# typed: false
# frozen_string_literal: true

module News
  module App
    class ApplicationController < ActionController::Base
      include ::Fuse
      include ::RateLimit
      include ::Preference::Regional
      include ::Authentication::User
      include ::Authorization::User
      include ::Verification::User
      include Pundit::Authorization
      include ::Finisher

      protect_from_forgery with: :exception

      allow_browser versions: :modern

      public_strict!
    end
  end
end
