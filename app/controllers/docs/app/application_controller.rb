# frozen_string_literal: true

module Docs
  module App
    class ApplicationController < ActionController::Base
      include ::Fuse
      include ::Preference::Regional
      include ::RateLimit
      include ::Auth::Base

      public_strict!

      protect_from_forgery with: :exception

      allow_browser versions: :modern
    end
  end
end
