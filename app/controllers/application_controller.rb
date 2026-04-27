# typed: false
# frozen_string_literal: true

class ApplicationController < ActionController::Base
  # Standard CSRF protection
  protect_from_forgery with: :exception
end
