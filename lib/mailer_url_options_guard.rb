# typed: false
# frozen_string_literal: true

module MailerUrlOptionsGuard
  class InvalidDefaultUrlOptionsError < StandardError; end

  module_function

  def validate!(default_url_options:, allowed_hosts: nil)
    host = default_url_options[:host].to_s.strip

    raise InvalidDefaultUrlOptionsError, "action_mailer.default_url_options host is required" if host.empty?
    if host.include?("://")
      raise InvalidDefaultUrlOptionsError,
            "action_mailer.default_url_options host must not include a scheme"
    end

    port = default_url_options[:port]
    if !port.nil? && !port.is_a?(Integer)
      raise InvalidDefaultUrlOptionsError, "action_mailer.default_url_options port must be an Integer"
    end

    return if allowed_hosts.nil?
    return if allowed_hosts.include?(host)

    raise InvalidDefaultUrlOptionsError,
          "action_mailer.default_url_options host #{host.inspect} is not in the allowed host list"
  end
end
