# frozen_string_literal: true

require "net/http"
require "json"
require "uri"

module Jit
  module Security
    class TurnstileVerifier
      VERIFY_URI = URI("https://challenges.cloudflare.com/turnstile/v0/siteverify").freeze

      # Configuration for testing
      # rubocop:disable ThreadSafety/ClassAndModuleAttributes, ThreadSafety/ClassInstanceVariable
      class << self
        attr_accessor :test_mode, :test_response

        def test_mode?
          @test_mode == true
        end
      end
      # rubocop:enable ThreadSafety/ClassAndModuleAttributes, ThreadSafety/ClassInstanceVariable

      def self.verify(token:, remote_ip:, secret_key: nil)
        new(token: token, remote_ip: remote_ip, secret_key: secret_key).verify
      end

      def initialize(token:, remote_ip:, secret_key: nil)
        @token = token
        @remote_ip = remote_ip
        @secret_key = secret_key || default_secret_key
      end

      def verify
        # Check test mode
        if self.class.test_mode? || self.class.test_response
          return self.class.test_response || { "success" => true }
        end

        return failure("missing cf-turnstile-response") if @token.blank?
        return failure("missing turnstile secret") if @secret_key.blank?

        perform_request
      rescue StandardError => e
        # Decoupled notification: only if Rails event system exists
        if defined?(Rails) && Rails.respond_to?(:event)
          Rails.event.notify("turnstile.verify.failed", error_class: e.class.name, error_message: e.message)
        end
        failure(e.message)
      end

      private

      def perform_request
        response = Net::HTTP.post_form(
          VERIFY_URI,
          {
            "secret" => @secret_key,
            "response" => @token,
            "remoteip" => @remote_ip,
          },
        )
        JSON.parse(response.body)
      end

      def default_secret_key
        return unless defined?(Rails)

        Rails.application.credentials.dig(:CLOUDFLARE, :TURNSTILE_SECRET_KEY) ||
          ENV["CLOUDFLARE_TURNSTILE_SECRET_KEY"]
      end

      def failure(message)
        { "success" => false, "error" => message }
      end
    end
  end
end
