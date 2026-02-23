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
      include ::Finisher

      protect_from_forgery with: :exception

      allow_browser versions: :modern

      public_strict!
    end
  end
end
