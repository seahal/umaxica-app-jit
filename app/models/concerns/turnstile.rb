# frozen_string_literal: true

require "net/http"
require "uri"

module Turnstile
  extend ActiveSupport::Concern

  VERIFY_URI = URI("https://challenges.cloudflare.com/turnstile/v0/siteverify").freeze

  # Test helper for mocking Turnstile responses in tests
  # rubocop:disable ThreadSafety/ClassAndModuleAttributes
  mattr_accessor :test_response
  # rubocop:enable ThreadSafety/ClassAndModuleAttributes

  included do
    attr_accessor :turnstile_response, :turnstile_remote_ip
    attr_writer :turnstile_error_message

    validates_with TurnstileValidator, if: :turnstile_required?
  end

  def require_turnstile(response:, remote_ip:, error_message: nil)
    self.turnstile_response = response
    self.turnstile_remote_ip = remote_ip
    @turnstile_error_message = error_message
    @turnstile_required = true
    @turnstile_result = nil
    self
  end

  def turnstile_valid?
    return true unless turnstile_required?

    turnstile_result["success"]
  end

  def turnstile_required?
    @turnstile_required
  end

  def turnstile_result
    @turnstile_result ||= self.class.verify_turnstile(
      turnstile_response: turnstile_response,
      remote_ip: turnstile_remote_ip,
    )
  end

  def turnstile_error_message
    @turnstile_error_message.presence || I18n.t("turnstile_error")
  end

  private :turnstile_result

  module ClassMethods
    def missing_response_error
      { "success" => false, "error" => "missing cf-turnstile-response" }
    end

    def missing_secret_error
      { "success" => false, "error" => "missing turnstile secret" }
    end

    def verify_turnstile(turnstile_response:, remote_ip:)
      return Turnstile.test_response if Turnstile.test_response

      return missing_response_error if turnstile_response.blank?

      secret_key = Rails.application.credentials.dig(:CLOUDFLARE, :TURNSTILE_SECRET_KEY) ||
        ENV["CLOUDFLARE_TURNSTILE_SECRET_KEY"]
      return missing_secret_error if secret_key.blank?

      response = Net::HTTP.post_form(VERIFY_URI, {
        "secret" => secret_key,
        "response" => turnstile_response,
        "remoteip" => remote_ip,
      })
      JSON.parse(response.body)
    rescue StandardError => e
      Rails.event.notify("turnstile.verify.failed", error_class: e.class.name, error_message: e.message)
      { "success" => false, "error" => e.message }
    end
  end
end
