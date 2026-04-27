# typed: false
# frozen_string_literal: true

class ApplicationController < ActionController::Base
  # NOTE: Abstract base controller.
  # Defines global CSRF protection and shared behavior.
  # Not intended for direct use or routing.

  include ::Preference::Localization

  # Standard CSRF protection
  protect_from_forgery with: :exception
end
