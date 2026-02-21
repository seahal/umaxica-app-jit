# frozen_string_literal: true

module Core
  module Com
    class ApplicationController < ActionController::Base
      include ::Fuse
      include ::RateLimit
      include ::Preference::Regional
      include ::Auth::User
      include Pundit::Authorization
      include ::Finisher

      protect_from_forgery with: :exception

      allow_browser versions: :modern

      public_strict!
    end
  end
end
