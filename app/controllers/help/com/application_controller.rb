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
      include ::Finisher

      protect_from_forgery with: :exception

      allow_browser versions: :modern

      public_strict!
    end
  end
end
