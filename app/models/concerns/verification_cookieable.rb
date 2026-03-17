# typed: false
# frozen_string_literal: true

module VerificationCookieable
  extend ActiveSupport::Concern

  COOKIE_BASENAME = "verification"
  SECURE_COOKIE_PREFIX = "__Secure-"

  class_methods do
    def cookie_name
      Rails.env.production? ? "#{SECURE_COOKIE_PREFIX}#{COOKIE_BASENAME}" : COOKIE_BASENAME
    end
  end
end
