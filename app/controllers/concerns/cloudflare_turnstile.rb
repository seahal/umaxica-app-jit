# typed: false
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
      Jit::Security::TurnstileVerifier.test_mode = true
      Jit::Security::TurnstileVerifier.test_response = CloudflareTurnstile.test_validation_response
      return CloudflareTurnstile.test_validation_response || { "success" => true }
    end

    Jit::Security::TurnstileVerifier.verify(
      token: params["cf-turnstile-response"].to_s,
      remote_ip: request.remote_ip,
      mode: :visible,
    )
  end
end
