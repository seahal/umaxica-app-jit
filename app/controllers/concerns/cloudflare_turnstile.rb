# frozen_string_literal: true

module CloudflareTurnstile
  extend ActiveSupport::Concern

  # Test helper for mocking Turnstile responses in tests
  # rubocop:disable ThreadSafety/ClassAndModuleAttributes
  mattr_accessor :test_mode
  mattr_accessor :test_validation_response
  # rubocop:enable ThreadSafety/ClassAndModuleAttributes

  private

  def cloudflare_turnstile_validation
    # In test mode, return the mock response
    if CloudflareTurnstile.test_mode
      return CloudflareTurnstile.test_validation_response || { "success" => true }
    end

    res = Net::HTTP.post_form(
      URI.parse("https://challenges.cloudflare.com/turnstile/v0/siteverify"),
      { "secret" => Rails.application.credentials.dig(:CLOUDFLARE, :TURNSTILE_SECRET_KEY),
        "response" => params["cf-turnstile-response"],
        "remoteip" => request.remote_ip, },
    )

    JSON.parse(res.body)
  end
end
