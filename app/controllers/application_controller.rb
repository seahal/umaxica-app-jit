# typed: false
# frozen_string_literal: true

class ApplicationController < ActionController::Base
  # NOTE: Abstract base controller.
  # Defines global CSRF protection and shared behavior.
  # Not intended for direct use or routing; inherit in concrete controllers.
  abstract!

  protect_from_forgery using: :header_or_legacy_token,
                       trusted_origins: [],
                       with: :exception
end
